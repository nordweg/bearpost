require 'rails_helper'

RSpec.describe Shipment, type: :model do
  context 'when shipped' do
    before do
      @shipment = Shipment.new
      @shipment.shipped_at = 10.days.ago
    end

    it 'knows it is shipped' do
      expect(@shipment.shipped?).to be true
    end

    it 'knows the shipping date' do
      expect(@shipment.shipped_at.to_date).to eq 10.days.ago.to_date
    end
  end
  context "when not shipped" do
    before do
      @shipment = Shipment.new
    end

    it "knows it wasn't shipped" do
      expect(@shipment.shipped?).to be false
    end
  end
end
