# app/models/concerns/link_click_analytics.rb
module LinkClickAnalytics
  extend ActiveSupport::Concern

  CACHE_EXPIRY = 5.minutes

  class_methods do
    def top_most_clicked_links(limit = 10)
      Rails.cache.fetch("top_most_clicked_links_#{limit}", expires_in: CACHE_EXPIRY) do
        select(:url)
          .group(:url)
          .order('COUNT(url) DESC')
          .limit(limit)
          .map(&:url)
      end
    end

    def clicks_by_day(limit = 10)
      Rails.cache.fetch("clicks_by_day_#{limit}", expires_in: CACHE_EXPIRY) do
        date_range = (5.days.ago.to_date..Date.yesterday.to_date).to_a
        clicks_count_per_day = where("created_at >= ?", limit.days.ago.beginning_of_day)
                                 .group("DATE(created_at)")
                                 .order("DATE(created_at)")
                                 .count

        date_range.reverse_each.each_with_object({}) do |date, hash|
          hash[date.to_s] = clicks_count_per_day[date.to_s] || 0
        end
      end
    end

    # Todo not in use anywhere yet
    def total_clicks_in_date_range(start_date, end_date)
      Rails.cache.fetch("total_clicks_in_date_range_#{start_date}_#{end_date}", expires_in: CACHE_EXPIRY) do
        where(created_at: start_date.beginning_of_day..end_date.end_of_day)
          .count
      end
    end
  end
end
