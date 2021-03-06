require "rails_helper"

RSpec.describe Locations::AuditsController, type: :controller do

  it "should get index" do
    location = create(:location_with_audits)
    get :index, location_id: location.id
    expect(assigns(:audits)).to eq(location.audits)
  end
end