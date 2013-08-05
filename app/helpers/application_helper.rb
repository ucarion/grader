module ApplicationHelper
  def full_title(title)
    base_title = "Grader"
    if title.empty?
      base_title
    else
      "#{base_title} | #{title}"
    end
  end

  def link_with_icon(icon, body, url, html_options = {})
    link_to(url, html_options) do
      content_tag(:i, '', class: "icon-fixed-width icon-#{icon}") + " " + body
    end
  end
end
