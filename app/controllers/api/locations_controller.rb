class Api::LocationsController < ApiController

  def index
    render json: Location.by_root
  end

  def show
    render json: current_resource
  end

  def create
    @location = LocationForm.new
    process_location(@location.submit(location_params))
  end

  def update
    @location = LocationForm.new(current_resource)
    process_location(@location.submit(location_params))
  end

private

  def current_resource
    Location.find_by_code(params[:barcode]) if params[:barcode]
  end

  def process_location(succeeded)
    if succeeded
      render json: @location, serializer: "#{@location.type}Serializer".constantize
    else
      render json: { errors: @location.errors.full_messages}, status: :unprocessable_entity
    end
  end

  def location_params
    params.permit(location: LocationForm.permitted_attributes)
  end

end
