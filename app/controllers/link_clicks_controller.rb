class LinkClicksController < ApplicationController
  protect_from_forgery with: :null_session

  rate_limit to: 60, within: 1.minute, only: :create

  def create
    # Note:
    # I can use caching to only enqueue job after 50 or 100 clicks for each ip or within 1 min
    # but I want to see instant stats, that's why skipping it
    # # Test code
    # cache_key = "link_click_batch_#{request.remote_ip}"
    # current_click_data = Rails.cache.fetch(cache_key, expires_in: 1.minute) { [] }
    # Merge new click data with cached data
    # current_click_data += link_click_params
    # only enqueue if click size exceeds 50 or 100 per ip
    # or enqueue another job to enqueue clicks before cache expires

    StoreLinkClickJob.perform_later(link_click_params) if link_click_params.present?
    render json: {}, status: :ok
  end

  private

  def link_click_params
    params.require(:link_click).map do |link_click|
      link_click.permit(:url, :anchor_text, :referrer, :created_at, :updated_at, :user_agent)
                .merge({ ip_address: request.remote_ip })
    end
  end
end
