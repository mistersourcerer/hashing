require "base64"

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
        hasherize :h

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
      new_object = hasherized.from_hash h: 'hasherizing'
      new_object.h.must_be :==, { h: 'hasherizing' }
    end

    it 'give an informative message in case the Hash is malformed' do
      OmgLolBBQ = hasherized
      message = nil
      proc {
        begin
          OmgLolBBQ.from_hash xpto: 'JUST NO!'
        rescue => e
          message = e.message
          raise e
        end
      }.must_raise Hashing::UnconfiguredIvar
      message.must_be :==, 'The Hash has a :xpto key, but no @xpto '+
        'was configured in OmgLolBBQ'
    end
  end

  describe '.hasherize' do
    let(:hasherized) do
      Class.new do
        include Hashing

        attr_reader :content

        hasherize :file, :commit
        hasherize :content,
          to_hash: ->(content) { Base64.encode64(content) },
          from_hash: ->(hash_string) { Base64.decode64(hash_string) }
        loading ->(hash) { new hash[:file], hash[:commit], hash[:content] }

        def initialize(file, commit, content)
          @file, @commit, @content = file, commit, content
        end
      end
    end

    it 'allows configure how to serialize a specific `ivar`' do
      file = hasherized.new 'README.md', 'cfe9aacbc02528b', '#Hashing\n\nWow. Such code...'
      file.to_h[:content].must_be :==, Base64.encode64('#Hashing\n\nWow. Such code...')
    end

    it 'allows configure how to load a value for a specific `ivar`' do
      file = hasherized.from_hash file: 'README.md',
        commit: 'cfe9aacbc02528b',
        content: Base64.encode64('#Hashing\n\nWow. Such code...')
      file.content.must_be :==, '#Hashing\n\nWow. Such code...'
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
