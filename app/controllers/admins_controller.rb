class AdminsController < ApplicationController
  before_action :prepare_data, only: :dashboard
  def dashboard
  end

  private

  def prepare_data
    @clicks_by_day = LinkClick.clicks_by_day(5)
    @top_clicked_links = LinkClick.top_most_clicked_links(5)
    @total_clicks = LinkClick.count
  end
end
