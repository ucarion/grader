module MarkdownHelper
  def markdown(text)
    markdown_parser.render(text).html_safe
  end

  private

  def markdown_parser
    renderer = CustomRenderers::HtmlWithPygments
    opts = {
      hard_wrap: true,
      fenced_code_blocks: true,
      autolink: true,
      disable_indented_code_blocks: true
    }

    Redcarpet::Markdown.new(renderer, opts)
  end
end
