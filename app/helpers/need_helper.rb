module NeedHelper
  include ActiveSupport::Inflector
  include ActionView::Helpers::NumberHelper

  def format_need_goal(goal)
    return "" if goal.blank?

    words = goal.split(" ")
    words.first[0] = words.first[0].upcase
    words.join(" ")
  end

  def format_field_value(value)
    value.present? ? value : "<em>blank</em>".html_safe
  end

  def format_field_name(name)
    name.titleize
  end

  # If no criteria present, insert a blank
  # one.
  def criteria_with_blank_value(criteria)
    criteria.present? ? criteria : [""]
  end

  def format_need_impact(impact)
    impact_key = impact.parameterize.underscore
    translated = t("needs.show.impact.#{impact_key}")

    "If GOV.UK didn't meet this need #{translated}."
  end

  def calculate_percentage(numerator, denominator)
    return unless numerator.present? and denominator.present?
    return if denominator == 0

    percent = numerator.to_f / denominator.to_f * 100.0

    # don't include the fractional part if the percentage is X.0%
    format = percent.modulo(1) < 0.1 ? "%.0f\%" : "%.1f\%"
    (format % percent)
  end

  def show_interactions_column?(need)
    [ need.monthly_user_contacts, need.monthly_site_views, need.monthly_need_views, need.monthly_searches ].select(&:present?).any?
  end

  def format_friendly_integer(number)
    if number >= 1000000
      "%.3g\m" % (number.to_f / 1000000)
    elsif number >= 10000
      "%.3g\k" % (number.to_f / 1000)
    else
      number_with_delimiter(number)
    end
  end

  def paginate_needs(needs)
    return unless needs.present? and needs.current_page.present? and needs.pages.present? and needs.page_size.present?

    Kaminari::Helpers::Paginator.new(self,
      current_page: needs.current_page,
      total_pages: needs.pages,
      per_page: needs.page_size,
      param_name: "page",
      remote: false
    ).to_s
  end
end
