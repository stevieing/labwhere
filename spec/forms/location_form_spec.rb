require "rails_helper"

RSpec.describe LocationForm, type: :model do 

  let(:params) { attributes_for(:location) }
  let(:controller_params) { { controller: "location", action: "create"} }
  let!(:administrator) { create(:administrator) }

  it "is not valid without an user" do
    location_form = LocationForm.new
    expect(location_form.submit(controller_params.merge(location: params))).to be_falsey
    expect(location_form).to_not be_valid
  end

  it "is not valid unless the location is valid" do
    location_form = LocationForm.new
    expect(location_form.submit(
      controller_params.merge(location: params.except(:name).merge(user_code: administrator.barcode))
    )).to be_falsey
    expect(location_form).to_not be_valid
  end

  it "is valid creates a new location" do
    location_form = LocationForm.new
    expect(location_form.submit(
      controller_params.merge(location: params.merge(user_code: administrator.barcode))
    )).to be_truthy
    expect(location_form).to be_valid
    expect(location_form.locations.first).to be_persisted
  end

  it "can be edited if exists" do
    location = create(:location)
    location_form = LocationForm.new(location)
    new_location = build(:location)
    res = location_form.submit(
      controller_params.merge(location: { name: new_location.name }
                                          .merge(user_code: administrator.barcode),
                              action: "update")
    )
    expect(res).to be_truthy
    expect(location.name).to eq(new_location.name)
  end 

  it "can be destroyed if it has not been used" do
    controller_params = { controller: "location", action: "create"} 
    params = ActionController::Parameters.new(controller_params)
    location = create(:location, name: 'Test Location')
    location_form = LocationForm.new(location)
    res = location_form.destroy(params.merge(user_code: administrator.barcode))
    expect(res).to be_truthy
  end

  it "should create the correct type of location dependent on the attributes" do
    location_form = LocationForm.new
    expect(location_form.submit(
      controller_params.merge(location: attributes_for(:unordered_location)
                                          .merge(user_code: administrator.barcode))
    )).to be_truthy
    expect(location_form.locations.first).to be_unordered
    expect(location_form.locations.first.coordinates).to be_empty

    location_form = LocationForm.new
    expect(location_form.submit(
      controller_params.merge(location: attributes_for(:ordered_location)
                                          .merge(user_code: administrator.barcode))
    )).to be_truthy
    expect(location_form.locations.first).to be_ordered
    expect(location_form.locations.first.coordinates.count).to eq(create(:ordered_location).coordinates.count)
  end
  
  describe "multiple locations" do
    it "are created if start and end are not empty" do
      location_form = LocationForm.new
      expect(location_form.submit(
        controller_params.merge(location: params.merge(range_from: "1",
                                                       range_to: "4",
                                                       user_code: administrator.barcode))
      )).to be_truthy
      expect(location_form).to be_valid
    end

    it "are not created if start is greater than end" do
      location_form = LocationForm.new
      expect(location_form.submit(
        controller_params.merge(location: params.merge(range_from: "2",
                                                       range_to: "1",
                                                       user_code: administrator.barcode))
      )).to be_falsey
      expect(location_form).to_not be_valid
    end
    
  end

end
