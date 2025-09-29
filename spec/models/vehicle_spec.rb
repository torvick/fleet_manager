require 'rails_helper'

RSpec.describe Vehicle, type: :model do
  it 'valida unicidad case-insensitive de vin' do
    create(:vehicle, vin: 'ABC123')
    v = build(:vehicle, vin: 'abc123')
    expect(v).not_to be_valid
  end

  it 'exige year en rango 1990..2050' do
    v = build(:vehicle, year: 2080)
    expect(v).not_to be_valid
  end
end
