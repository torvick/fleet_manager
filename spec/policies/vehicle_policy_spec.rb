require 'rails_helper'

RSpec.describe VehiclePolicy, type: :policy do
  let(:vehicle) { create(:vehicle) }

  describe 'admin user' do
    let(:user) { create(:user, role: :admin) }
    let(:policy) { described_class.new(user, vehicle) }

    it 'allows all actions' do
      expect(policy.index?).to be true
      expect(policy.show?).to be true
      expect(policy.create?).to be true
      expect(policy.update?).to be true
      expect(policy.destroy?).to be true
    end
  end

  describe 'manager user' do
    let(:user) { create(:user, role: :manager) }
    let(:policy) { described_class.new(user, vehicle) }

    it 'allows most actions but not destroy' do
      expect(policy.index?).to be true
      expect(policy.show?).to be true
      expect(policy.create?).to be true
      expect(policy.update?).to be true
      expect(policy.destroy?).to be false
    end
  end

  describe 'viewer user' do
    let(:user) { create(:user, role: :viewer) }
    let(:policy) { described_class.new(user, vehicle) }

    it 'allows only read actions' do
      expect(policy.index?).to be true
      expect(policy.show?).to be true
      expect(policy.create?).to be false
      expect(policy.update?).to be false
      expect(policy.destroy?).to be false
    end
  end

  describe 'Scope' do
    let(:admin) { create(:user, role: :admin) }
    let(:manager) { create(:user, role: :manager) }
    let(:viewer) { create(:user, role: :viewer) }

    before do
      create_list(:vehicle, 3)
    end

    it 'returns all vehicles for all user types' do
      expect(Pundit.policy_scope(admin, Vehicle).count).to eq(3)
      expect(Pundit.policy_scope(manager, Vehicle).count).to eq(3)
      expect(Pundit.policy_scope(viewer, Vehicle).count).to eq(3)
    end
  end
end
