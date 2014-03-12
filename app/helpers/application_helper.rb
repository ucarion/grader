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
    when :alert, :error
      :danger
    else
      type
    end
  end
end
