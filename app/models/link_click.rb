class LinkClick < ApplicationRecord
  include LinkClickAnalytics

  VALID_URL_REGEX = /\A(http|https):\/\/[^\s$.?#].[^\s]*\z/i

  validates :url, presence: true, format: { with: VALID_URL_REGEX }
  validates :anchor_text, :referrer, presence: true
  validate :valid_ip_address, if: -> { ip_address.present? }

  private

  def valid_ip_address
    begin
      IPAddr.new(ip_address)
    rescue IPAddr::InvalidAddressError
      errors.add(:ip_address, "is invalid")
    end
  end
end
