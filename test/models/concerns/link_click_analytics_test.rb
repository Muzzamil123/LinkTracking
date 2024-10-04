require 'test_helper'

class LinkClickAnalyticsTest < ActiveSupport::TestCase
  def setup
    Rails.cache.clear
    LinkClick.delete_all
    LinkClick.create(url: "http://example.com", anchor_text: "Example Anchor", referrer: "http://referrer.com", created_at: 5.days.ago)
    LinkClick.create(url: "http://example.com", anchor_text: "Example Anchor", referrer: "http://referrer.com", created_at: 5.days.ago)
    LinkClick.create(url: "http://test.com", anchor_text: "Example Test", referrer: "http://referrer.com", created_at: 4.days.ago)
    LinkClick.create(url: "http://test.com", anchor_text: "Example Test", referrer: "http://referrer.com", created_at: 3.days.ago)
    LinkClick.create(url: "http://test.com", anchor_text: "Example Test", referrer: "http://referrer.com", created_at: 2.days.ago)
    LinkClick.create(url: "http://example.org", anchor_text: "Example Org", referrer: "http://referrer.com", created_at: 1.days.ago)
  end

  test "top_most_clicked_links returns the most clicked links when cache is empty" do
    Rails.cache.clear
    expected_result = ["http://test.com", "http://example.com", "http://example.org"]
    actual_result = LinkClick.top_most_clicked_links(5)

    assert_equal expected_result, actual_result
  end

  test 'top_most_clicked_links returns the most clicked links from cache' do
    cached_result = ["http://test.com", "http://example.com"]
    Rails.cache.write("top_most_clicked_links_5", ["http://test.com", "http://example.com"])
    actual_result = LinkClick.top_most_clicked_links(5)

    assert_equal cached_result, actual_result
  end


  test "clicks_by_day returns click counts per day when cache is empty" do
    Rails.cache.clear
    expected_result = {
      1.day.ago.to_date.to_s => 1,
      2.days.ago.to_date.to_s => 1,
      3.days.ago.to_date.to_s => 1,
      4.days.ago.to_date.to_s => 1,
      5.days.ago.to_date.to_s => 2
    }
    actual_result = LinkClick.clicks_by_day(5)

    assert_equal expected_result, actual_result
  end

  test 'clicks_by_day returns click counts per day from cache' do
    cached_result = {
      1.day.ago.to_date.to_s => 1,
      2.days.ago.to_date.to_s => 1,
      3.days.ago.to_date.to_s => 1
    }
    Rails.cache.write("clicks_by_day_5", cached_result)
    actual_result = LinkClick.clicks_by_day(5)

    assert_equal cached_result, actual_result
  end

  test "total_clicks_in_date_range returns click counts within specified range when cache is empty" do
    Rails.cache.clear
    start_date = 5.days.ago
    end_date = 3.day.ago
    expected_result = 4
    actual_result = LinkClick.total_clicks_in_date_range(start_date, end_date)

    assert_equal expected_result, actual_result
  end

  test "total_clicks_in_date_range returns click counts within specified range from cache" do
    Rails.cache.clear
    start_date = 5.days.ago
    end_date = 3.day.ago
    cached_result = 3
    Rails.cache.write("total_clicks_in_date_range_#{start_date}_#{end_date}", cached_result)
    actual_result = LinkClick.total_clicks_in_date_range(start_date, end_date)

    assert_equal cached_result, actual_result
  end
end
