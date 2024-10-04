require 'test_helper'

class LinkClickTest < ActiveSupport::TestCase
  def valid_url
    "http://example.com"
  end

  def valid_anchor_text
    "Example Anchor"
  end

  def valid_referrer
    "http://referrer.com"
  end

  def valid_ip_address
    "192.168.1.1"
  end

  test "does not save link click without url" do
    link_click = LinkClick.new(anchor_text: valid_anchor_text, referrer: valid_referrer)
    assert_not link_click.save
    assert_includes link_click.errors[:url], "can't be blank"
  end

  test "does not save link click without anchor_text" do
    link_click = LinkClick.new(url: valid_url, referrer: valid_referrer)
    assert_not link_click.save
    assert_includes link_click.errors[:anchor_text], "can't be blank"
  end

  test "does not save link click without referrer" do
    link_click = LinkClick.new(url: valid_url, anchor_text: valid_anchor_text)
    assert_not link_click.save
    assert_includes link_click.errors[:referrer], "can't be blank"
  end

  test "does not save link click with invalid url" do
    link_click = LinkClick.new(url: "invalid-url", anchor_text: valid_anchor_text, referrer: valid_referrer)
    assert_not link_click.save
    assert_includes link_click.errors[:url], "is invalid"
  end

  test "does not save link click with invalid ip_address" do
    link_click = LinkClick.new(url: valid_url, anchor_text: valid_anchor_text, referrer: valid_referrer,
                               ip_address: "invalid-ip-address")
    assert_not link_click.save
    assert_includes link_click.errors[:ip_address], "is invalid"
  end

  test "should save link click with all valid attributes" do
    link_click = LinkClick.new(url: valid_url, anchor_text: valid_anchor_text, referrer: valid_referrer,
                               ip_address: valid_ip_address)
    assert link_click.save
  end
end
