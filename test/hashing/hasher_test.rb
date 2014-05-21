describe Hashing::Hasher do
  before do
    class WowSuchClass
    end
  end

  let(:hasher) { Hashing::Hasher.new WowSuchClass }

  describe "#attr" do
    it "with true, provides attr_readers for the current ivars" do
      hasher.add(:very_ivar).reader true
      WowSuchClass.new.respond_to?(:very_ivar).must_be :==, true
    end
  end
end
