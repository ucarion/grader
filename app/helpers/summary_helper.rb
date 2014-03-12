module SummaryHelper
  # Summarizes a piece of Markdown text, for use in views.
  def summarize(text, opts = {})
    max_length = opts[:max_length] || 70

    first_line = text.split("\n").first || ""
    rendered = Nokogiri::HTML(markdown(first_line))

    first_paragraph = rendered.css('p').first
    first_paragraph_text = first_paragraph.try(:text) || ""

    if first_paragraph_text.length > max_length
      "#{first_paragraph_text[0...max_length]} ..."
    else
      first_paragraph_text
    end
  end
end
