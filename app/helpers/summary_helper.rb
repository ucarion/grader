module SummaryHelper
  # Summarizes a piece of Markdown text, for use in views.
  def summarize(text, opts = {})
    max_length = opts[:max_length] || 30

    first_line = text.split("\n").first
    rendered = Nokogiri::HTML(markdown(first_line))
    first_paragraph = rendered.css('p').first

    first_paragraph.text[0...max_length]
  end
end
