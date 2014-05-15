describe Hasherize do
  let(:hasherized) do
    Class.new do
      attr_reader :file, :commit

      include Hasherize.new(:file, :commit).
        to(->(value) { "X-#{value}" }).
        from(->(value) { "#{value}-X" }).
        loading(->(params) { new params[:file], params[:commit] })

      def initialize(file, commit)
        @file, @commit = file, commit
      end
    end
  end

  it "just sugar to `include Hashing` and call `hasherize`" do
    hasherized.ancestors.include?(Hashing).must_be :==, true
  end

  it "configures the ivars correctly (so I can recreate instances by Hash)" do
    object = hasherized.from_hash file: 'README.md', commit: 'omglolbbq123'
    object.file.must_be :==, 'README.md-X'
    object.commit.must_be :==, 'omglolbbq123-X'
  end

  it "configure `:to` e `:from` serialization strategies" do
    object = hasherized.new 'README.md', 'omglolbbq123'
    object.to_h.must_be :==, { file: 'X-README.md', commit: 'X-omglolbbq123' }
  end
end
