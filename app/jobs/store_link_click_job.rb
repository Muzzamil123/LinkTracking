class StoreLinkClickJob < ApplicationJob
  queue_as :default

  def perform(link_clicks)
    LinkClick.create!(link_clicks)
  end
end
