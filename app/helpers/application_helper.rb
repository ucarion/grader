module ApplicationHelper
  def full_title(title)
    base_title = "Grader"
    if title.empty?
      base_title
    else
      "#{base_title} | #{title}"
    end
  end

  # TODO: get rid of this blasted method
  def link_with_icon(icon, body, url, html_options = {})
    link_to(url, html_options) do
      content_tag(:i, '', class: "icon-fixed-width icon-#{icon}") + " " + body
    end
  end

  def markdown(text)
    markdown_parser.render(text).html_safe
  end

  def submit_btn(text, params)
    opts = {
      type: :submit
    }.merge(params)

    content_tag(:button, text, opts)
  end

  def class_for_flash_type(type)
    case type.to_sym
    when :notice
      :info
    when :alert
      :danger
    else
      type
    end
  end

  private

  def markdown_parser
    renderer = CustomRenderers::HtmlWithPygments
    opts = {
      hard_wrap: true,
      fenced_code_blocks: true,
      autolinks: true,
      disable_indented_code_blocks: true
    }

    Redcarpet::Markdown.new(renderer, opts)
  end
end
