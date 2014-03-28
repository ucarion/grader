module ActivityHelper
  def activity_time_ago(activity)
    content_tag(:span, time_ago_in_words(activity.created_at) + " ago",
      class: 'activity-timestamp') + " &mdash;".html_safe
  end
end
