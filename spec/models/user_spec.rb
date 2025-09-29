require 'rails_helper'

RSpec.describe User, type: :model do
  it 'downcasing de email y unicidad' do
    create(:user, email: 'ADMIN@EXAMPLE.COM')
    u = build(:user, email: 'admin@example.com')
    expect(u).not_to be_valid
  end

  it 'requiere password mínimo 8 chars' do
    u = build(:user, password: 'short')
    expect(u).not_to be_valid
  end
end
