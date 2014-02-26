module CustomRenderers
  class HtmlWithPygments < Redcarpet::Render::HTML
    def block_code(code, language)
      Pygments.highlight(code, :lexer => language)
    end
  end
end

MarkdownRails.configure do |config|
  renderer = CustomRenderers::HtmlWithPygments
    opts = {
      hard_wrap: true,
      fenced_code_blocks: true,
      autolinks: true,
      disable_indented_code_blocks: true
    }

  markdown = Redcarpet::Markdown.new(renderer, opts)

  config.render do |markdown_source|
    markdown.render(markdown_source)
  end
end
