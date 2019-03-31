# == Schema Information
#
# Table name: adjustments
#
#  id                  :integer          not null, primary key
#  organization_id     :integer
#  storage_location_id :integer
#  comment             :text
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#

class Adjustment < ApplicationRecord
  belongs_to :organization
  belongs_to :storage_location

  include Itemizable
  include Filterable
  scope :at_location, ->(location_id) { where(storage_location_id: location_id) }
  scope :for_csv_export, ->(organization) {
    where(organization: organization)
      .includes(:storage_location, :line_items)
  }

  validates :storage_location, :organization, presence: true
  validate :line_item_items_exist_in_inventory
  validate :storage_locations_belong_to_organization

  def self.storage_locations_adjusted_for(organization)
    includes(:storage_location).where(organization_id: organization.id).collect(&:storage_location)
  end

  def split_difference
    # Adjustments are weird. They'll have positive AND negative values, instead
    # of just one or the other. Negative values mean "decrease", positive values
    # mean "increase". Because Storage location only needs an Itemizable duck,
    # We're going to create two temporary copies, one for increasing and one
    # for decreasing.

    increasing_adjustment = ::Adjustment.new
    decreasing_adjustment = ::Adjustment.new

    line_items.replicate_to(increasing_adjustment) do |line_item|
      next if line_item.quantity.negative?
    end

    line_items.replicate_to(decreasing_adjustment) do |line_item|
      next if line_item.quantity.positive?
    end

    [increasing_adjustment, decreasing_adjustment]
  end

  def self.csv_export_headers
    ["Created", "Organization", "Storage Location", "Comment", "Changes"]
  end

  def csv_export_attributes
    [
      created_at.strftime("%F"),
      organization.name,
      storage_location.name,
      comment,
      line_items.count
    ]
  end

  private

  def storage_locations_belong_to_organization
    return if organization.nil?

    unless organization.storage_locations.include?(storage_location)
      errors.add :storage_location, "storage location must belong to organization"
    end
  end
end
