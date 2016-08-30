class School < ActiveRecord::Base
  has_many :Implementer_requests, dependent: :destroy

  geocoded_by :address
  after_validation :geocode, if: ->(obj){ obj.address.present? and obj.address_changed? }
end
