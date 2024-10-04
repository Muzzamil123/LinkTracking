require 'test_helper'

class StoreLinkClickJobTest < ActiveJob::TestCase
  def link_click_attributes
    {
      url: "http://example.com",
      anchor_text: "Example",
      referrer: "http://referrer.com",
      created_at: Time.now,
      updated_at: Time.now,
      user_agent: "Mozilla/5.0",
      ip_address: "127.0.0.1"
    }
  end

  test "should create link clicks when job is performed" do
    link_clicks = [link_click_attributes]

    assert_difference 'LinkClick.count', 1 do
      perform_enqueued_jobs do
        StoreLinkClickJob.perform_later(link_clicks)
      end
    end
  end

  test "should not create link clicks when empty array is provided" do
    empty_link_clicks = []

    assert_no_difference 'LinkClick.count' do
      perform_enqueued_jobs do
        StoreLinkClickJob.perform_later(empty_link_clicks)
      end
    end
  end

  test "should process multiple jobs without issues" do
    link_click_1 = link_click_attributes.merge({ url: "http://example1.com", anchor_text: "Example 1" })
    link_click_2 = link_click_attributes.merge({ url: "http://example2.com", anchor_text: "Example 2" })

    assert_difference 'LinkClick.count', 2 do
      perform_enqueued_jobs do
        StoreLinkClickJob.perform_later([link_click_1])
        StoreLinkClickJob.perform_later([link_click_2])
      end
    end
  end
end
