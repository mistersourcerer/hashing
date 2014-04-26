describe Hashing do
  describe 'interface' do
    let(:hasherized) do
      # if in doubt about the absense of assertions in this test, please
      # refer to:
      # - http://blog.zenspider.com/blog/2012/01/assert_nothing_tested.html
      # and https://github.com/seattlerb/minitest/issues/159
      Class.new do
        include Hashing
        hasherize :ivar
        loading ->() {}
      end
    end

    it 'adds the ::from_hash method' do
      hasherized.respond_to?(:from_hash).must_be :==, true
    end

    it 'adds the #to_h method' do
      hasherized.new.respond_to?(:to_h).must_be :==, true
    end
  end# interface

  describe 'Recreating a `hasherized` class instance' do
    let(:hasherized) do
      Class.new do
        attr_reader :h

        include Hashing

        def initialize(h)
          @h = h
        end
      end
    end

    it 'uses (`#call`) the strategy defined by `.loading`' do
      called = false
      my_strategy = ->(h) { called = true }
      hasherized.send :loading, my_strategy
      hasherized.from_hash Hash.new
      called.must_be :==, true
    end

    it 'just calls .new if none strategy was defined by .loading' do
      new_object = hasherized.from_hash test: 'hasherizing'
      new_object.h.must_be :==, { test: 'hasherizing' }
    end
  end

  describe '#to_h' do
    let(:hasherized) do
      Class.new do
        include Hashing
        hasherize :file, :commit
        loading ->(hash) { new hash[:file], hash[:commit] }

        def initialize(file, commit)
          @file, @commit = file, commit
        end
      end
    end

    it 'creates a hash using the ivars based on `.hasherize`' do
      object = hasherized.new 'README.md', 'cfe9aacbc02528b'
      object.to_h.must_be :==, { file: 'README.md', commit: 'cfe9aacbc02528b' }
    end
  end
end
