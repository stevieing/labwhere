# Serializer for Location
# includes created_at and updated_at
class LocationSerializer < ActiveModel::Serializer
  
  self.root = false

  attributes :id, :name, :parent, :container, :status, :location_type_id, :labwares, :audits, :barcode, :children, :parentage

  include SerializerDates

  ##
  # If the parent is not valid return its name
  # otherwise return a link to the parent
  def parent
    unless object.parent.empty? || object.parent.unknown?
      api_location_path(object.parent.barcode)
    else
      object.parent.name
    end
  end

  ##
  # Link to the labwares for the location
  def labwares
    api_location_labwares_path(object.barcode)
  end

  ##
  # Link to the audits for the location
  def audits
    api_location_audits_path(object.barcode)
  end

  ##
  # Link to the children for the location
  def children
    api_location_children_path(object.barcode)
  end

end
