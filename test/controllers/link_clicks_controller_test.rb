require 'test_helper'

class LinkClicksControllerTest < ActionDispatch::IntegrationTest
  def link_click_params
    {
      link_click: [
        {
          url: "http://example.com",
          anchor_text: "Example",
          referrer: "http://referrer.com",
          created_at: Time.now,
          updated_at: Time.now,
          user_agent: "Mozilla/5.0"
        }
      ]
    }
  end

  test "should enqueue StoreLinkClickJob when valid params are provided" do
    assert_enqueued_jobs 0

    assert_enqueued_with(job: StoreLinkClickJob) do
      post link_clicks_url, params: link_click_params, as: :json
    end

    assert_response :ok
  end

  test "should not enqueue job when no params are provided" do
    post link_clicks_url, params: {}, as: :json

    assert_enqueued_jobs 0
    assert_response 400
  end

  test "should not enqueue job when rate limit is exceeded" do
    60.times { post link_clicks_url, params: link_click_params, as: :json }

    assert_response :ok

    post link_clicks_url, params: link_click_params, as: :json
    assert_response :too_many_requests
  end
end
