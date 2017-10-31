##
# Form object for a Location
class LocationForm

  include ActiveModel::Model
  include ActiveModel::Serialization

  CONTROLLER_ATTRIBUTES = [:controller, :action]
  FORM_ATTRIBUTES = [:user_code, :range_from, :range_to, :reserve]
  LOCATION_ATTRIBUTES = [:id, :name, :location_type_id, :parent_id, :container, :status, :rows, :columns]
  
  attr_writer :coordinateable, :reserve
  attr_reader :user_code, :controller, :action, :location, :locations, :range_from, :range_to, :params
  attr_accessor *CONTROLLER_ATTRIBUTES

  alias_attribute :current_user, :user_code

  # delegate_missing_to :location # rails 5
  delegate :parent, :barcode, :parentage, :type, :coordinateable?, :reserved?, :reserved_by, to: :location
  delegate :created_at, :updated_at, :to_json, to: :location 
  delegate *LOCATION_ATTRIBUTES, to: :location

  validate :check_user, :check_location, :check_locations, :check_range, :only_same_team_can_release_location

  def self.permitted_attributes
    LOCATION_ATTRIBUTES + FORM_ATTRIBUTES
  end

  def initialize(location = nil)
    @location = location || Location.new
  end

  def submit(params)
    @params = params
    assign_attributes(params)
    @locations = LocationAggregator.new(location: location, range_from: range_from, range_to: range_to, team: team)
    if valid?
      locations.save
      @location = locations.first
    else
      false
    end
  end

  def destroy(params)
    @params = params
    self.user_code = params[:user_code]
    return false unless valid?
    location.destroy
    if location.destroyed?
      true
    else
      add_errors(location)
      false
    end
  end

  def check_user
    UserValidator.new.validate(self) 
  end

  def check_location
    return if location.valid?
    add_errors(location)
  end

  def check_locations
    return if locations.nil?
    return if locations.valid?
    add_errors(locations)
  end

  def check_range
    return unless range_from.present? && range_to.present?
    return unless range_from > range_to
    errors.add(:range_from, :invalid, message: "must be less than End")
  end

  def self.model_name
    ActiveModel::Name.new(Location)
  end

  def reserve
    return reserved? if @reserve.nil?
    @reserve
  end

  def coordinateable
    @coordinateable ||= coordinateable?
  end

  def persisted?
    location.id?
  end

  def user_code=(user_code)
    @user_code = User.find_by_code(user_code)
  end

  def range_from=(range_from)
    @range_from = (range_from || 1).to_i
  end

  def range_to=(range_to)
    @range_to = (range_to || 1).to_i
  end

  def reserve=(reserve)
    @reserve = ((reserve || "0") == "1")
  end

  def unreserved?
    !reserve?
  end

  def reserve?
    reserve
  end

  private

  def assign_attributes(params)
    assign_form_attributes(flattened_params)
    @location.assign_attributes(location_attributes)
  end

  def assign_form_attributes(params)
    (FORM_ATTRIBUTES + CONTROLLER_ATTRIBUTES).each do |attribute|
      self.send("#{attribute}=", params[attribute])
    end
  end

  def add_errors(object)
    object.errors.each do |key, value|
      errors.add key, value
    end
  end

  def team
    reserve? ? current_user.team_id : nil
  end

  def flattened_params
    @flattened_params ||= params.except(:location).merge(params[:location])
  end

  def location_attributes
    @location_attributes ||= flattened_params.slice(*LOCATION_ATTRIBUTES)
  end

  def only_same_team_can_release_location
    return unless params.has_key? :location
    LocationReleaseValidator.new(team_id: current_user.team_id).validate(self) if unreserved?
  end

  class LocationAggregator
    include ActiveModel::Model
    include Enumerable

    attr_accessor :location, :range_from, :range_to, :team
    attr_reader :locations

    validate :check_locations

    def initialize(params = {})
      super
      location.team_id = team
      @locations = create_locations
    end

    def multiple?
      range_from != range_to
    end

    def save
      return false unless valid?
      begin
        ActiveRecord::Base.transaction do
          locations.each(&:save)
        end
        true
      rescue
        false
      end
    end

    def each(&block)
      locations.each(&block)
    end

    private

    def create_locations
      if multiple?
        aggregate_locations
      else
        @location = transform_location(location)
        [location]
      end
    end

    def aggregate_locations
      [].tap do |locations|
        (range_from..range_to).each do |n|
          new_location = location.dup
          new_location.name = "#{location.name}#{n}"
          locations << transform_location(new_location)
        end
      end
    end

    def transform_location(location)
      return location unless location.new_record?
      location.transform
    end

    def check_locations
      locations.each do |location|
        next if location.valid?
        location.errors.each do |key, value|
          errors.add key, value
        end
      end
    end

  end

end
