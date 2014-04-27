describe Hashing::Ivar do
  it "knows it's ivar name" do
    ivar = Hashing::Ivar.new :file
    ivar.name.must_be :==, :file
  end

  describe '#to_h' do
    it "uses the lambda passed as parameter to transform the value" do
      called = false
      ivar = Hashing::Ivar.new :file, ->(value) { called = value }
      ivar.to_h 'some value'
      called.must_be :==, 'some value'
    end

    it "by default just returns the value as is" do
      Hashing::Ivar.new(:file).to_h('x').must_be :==, 'x'
    end
  end

  describe '#from_hash' do
    it "uses the lambda passed as parameter to transform the value" do
      called = false
      ivar = Hashing::Ivar.new :file, nil, ->(value) { called = value }
      ivar.from_hash 'loading hash'
      called.must_be :==, 'loading hash'
    end

    it "by default just returns the value as is" do
      Hashing::Ivar.new(:file).from_hash('x').must_be :==, 'x'
    end
  end
end
