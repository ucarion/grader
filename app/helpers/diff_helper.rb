module DiffHelper
  def diff_submissions(submisison_a, submisison_b)
    source_a = File.read(submisison_a.main_file.code.path)
    source_b = File.read(submisison_b.main_file.code.path)

    diff_between(source_a, source_b)
  end

  # Generates a table showing the difference between two files.
  def diff_between(string_a, string_b)

    # Diffy returns a list of 'chunks', where insertions, deletions, and
    # unchanged sequences of lines are grouped up. This method ungroups them so
    # that they're easier to display line-by-line.
    def diff_chunks(string_a, string_b)
      string_a = sanitize_for_comparison(string_a)
      string_b = sanitize_for_comparison(string_b)

      diff = ::Diffy::Diff.new(string_a, string_b)
      diff.each_chunk.map do |chunk|
        # Ignore messages about newlines at the end of files; most teachers will
        # probably not put any ending newlines when they specify the expected
        # output.
        if chunk == "\\ No newline at end of file\n"
          []
        else
          chunk.split("\n")
        end
      end.flatten
    end

    def chunks_as_html(chunks)
      def diff_line(line_class, &block)
        content_tag(:tr, class: line_class, &block)
      end

      def diff_line_number(line_number, should_show_number)
        content_tag(:td, should_show_number ? line_number : "",
          class: 'diff-line-number')
      end

      def diff_line_code(text)
        content_tag(:td,
          content_tag(:span, text, class: 'diff-line')
        )
      end

      safe_empty = "".html_safe

      # These are the line numbers that will be shown off to the left of the
      # code. Because insertions and deletions only exist in one and not both
      # files, these two values will not always be the same.
      line_numbers = {a: 0, b: 0}

      chunks.reduce(safe_empty) do |acc, chunk|
        line_type = case chunk[0]
        when '+'
          :insertion
        when '-'
          :deletion
        else
          :unchanged
        end.to_s.inquiry

        # This is important because unchanged lines will have a leading space
        # that browsers will not normally show.
        chunk_to_html = if line_type.unchanged?
          # the [1..-1] is to avoid putting in the leading space twice
          "&nbsp;".html_safe + chunk[1..-1]
        else
          chunk
        end

        # Both line numbers incremented when line_type is 'unchanged'
        line_numbers[:a] += 1 unless line_type.deletion?
        line_numbers[:b] += 1 unless line_type.insertion?

        acc + diff_line(line_type.to_s) do
          diff_line_number(line_numbers[:a], !line_type.deletion?) +
          diff_line_number(line_numbers[:b], !line_type.insertion?) +
          diff_line_code(chunk_to_html)
        end
      end
    end

    table_content = chunks_as_html(diff_chunks(string_a, string_b))

    content_tag(:table, table_content,
      class: 'table table-bordered table-condensed table-diff')
  end
end
