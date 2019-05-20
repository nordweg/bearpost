require 'rails_helper'

RSpec.describe Shipment, type: :model do
  it "is valid with valid attributes" do
    shipment = Shipment.new(invoice_series:1, invoice_number:1)
    expect(shipment).to be_valid
  end
  it "is not valid without invoice series" do
    shipment = Shipment.new(invoice_number:1)
    expect(shipment).to_not be_valid
  end
  it "is not valid without invoice number" do
    shipment = Shipment.new(invoice_series:1)
    expect(shipment).to_not be_valid
  end

  describe "when related to the same order" do
    before do
      Shipment.create(
        order_number:1,
        invoice_series:1,
        invoice_number:123,
        shipment_number:"123"
      )
    end
    it "is valid with unique shipment numbers" do
      shipment = Shipment.new(
        order_number:1,
        invoice_series:1,
        invoice_number:1,
        shipment_number:"456"
      )
      expect(shipment).to be_valid
    end
    it "is not valid with the same shipment number" do
      shipment = Shipment.new(
        order_number:1,
        invoice_series:1,
        invoice_number:1,
        shipment_number:"123"
      )
      expect(shipment).to_not be_valid
    end
  end

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
