require './lib/payload'

RSpec.describe "Payload" do
  describe "Amount" do
    it "must be a string" do
      payload = Payload.build do |config|
        config.set_amount = 10.0
      end

      expect(payload.amount).to be_kind_of(String)
    end
    
    it "has 2 decimals" do
      payload = Payload.build do |config|
        config.set_amount = 10.00
      end

      expect(payload.amount).to eq("10.00")
    end
  end
end

