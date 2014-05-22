describe Hashing::Hasher do
  before do
    class WowSuchClass
      include Hashing
      def initialize(so_ivar = nil)
        @so_ivar = so_ivar
      end
    end
  end

  let(:hasher) { Hashing::Hasher.new WowSuchClass }

  describe "#attr" do
    it "with true, provides attr_readers for the current ivars" do
      hasher.add(:very_ivar).reader true
      WowSuchClass.new.respond_to?(:very_ivar).must_be :==, true
    end
  end

  describe "#using" do
    require 'base64'

    it "stores an object with methods to transform the current ivar" do
      class WowSuchClass
        hasherize(:so_ivar).reader(true).
          using(Base64).to(:encode64).from(:decode64).
          loading ->(hash) { new hash[:so_ivar] }
      end

      wow = WowSuchClass.new "borba"
      wow.to_h.must_be :==, {so_ivar: Base64.encode64("borba")}
      WowSuchClass.from_hash({so_ivar: Base64.encode64("borba")}).so_ivar.must_be :==, 'borba'
    end
  end
end
