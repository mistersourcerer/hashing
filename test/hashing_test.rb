require "base64"

describe Hashing do
  describe 'interface' do
    let(:hasherized) do
      Class.new do
        include Hashing
        hasherize(:ivar)
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
    describe '.loading' do

      before do
        @original_stdout, $stdout = $stdout, StringIO.new
      end

      after do
        $stdout = @original_stdout
      end

      it 'uses (`#call`) the strategy defined by `.loading`' do
        Class.new do
          include Hashing
          hasherize(:omg).loading ->(hash) { $stdout.write hash }
        end.from_hash omg: 'lol'
        $stdout.string.must_be :==, '{:omg=>"lol"}'
      end
    end

    describe '#from_hash' do
      it 'default strategy is just call `.new` passing the hash' do
        new_object = Class.new do
          attr_reader :h

          include Hashing
          hasherize :omg

          def initialize(h)
            @h = h
          end
        end.from_hash omg: 'lol'

        new_object.h.must_be :==, { omg: 'lol' }
      end

      it 'give an informative message in case the Hash is malformed' do
        OmgLolBBQ = Class.new do
          include Hashing
          hasherize(:h).loading ->(hash) { $stdout.write hash }
        end

        message = nil

        -> {
          begin
            OmgLolBBQ.from_hash xpto: 'JUST NO!'
          rescue => e
            message = e.message
            raise e
          end
        }.must_raise Hashing::UnconfiguredIvar

        message.must_be :==, 'The hash passed to OmgLolBBQ.from_hash has the '+
          'following keys that aren\'t configured by the .hasherize method: '+
          'xpto.'
      end
    end
  end

  describe '.hasherize' do
    let(:hasherized) do
      Class.new do
        include Hashing

        attr_reader :content

        hasherize :file, :commit
        hasherize(:content).
          to(->(content) { Base64.encode64(content) }).
          from(->(hash_string) { Base64.decode64(hash_string) }).
          loading(->(hash) { new hash[:file], hash[:commit], hash[:content] })

        def initialize(file, commit, content)
          @file, @commit, @content = file, commit, content
        end
      end
    end

    it 'allows configure how to serialize a specific `ivar`' do
      file = hasherized.new 'README.md', 'cfe9aacbc02528b', '#Hashing\n\nWow. Such code...'
      file.to_h[:content].must_be :==, Base64.encode64('#Hashing\n\nWow. Such code...')
    end

  #  it 'allows configure how to load a value for a specific `ivar`' do
  #    file = hasherized.from_hash file: 'README.md',
  #      commit: 'cfe9aacbc02528b',
  #      content: Base64.encode64('#Hashing\n\nWow. Such code...')
  #    file.content.must_be :==, '#Hashing\n\nWow. Such code...'
  #  end
  end

  #describe '#to_h' do
  #  let(:hasherized) do
  #    Class.new do
  #      include Hashing
  #      hasherize :file, :commit
  #      loading ->(hash) { new hash[:file], hash[:commit] }

  #      def initialize(file, commit)
  #        @file, @commit = file, commit
  #      end
  #    end
  #  end

  #  it 'creates a hash using the ivars based on `.hasherize`' do
  #    object = hasherized.new 'README.md', 'cfe9aacbc02528b'
  #    object.to_h.must_be :==, { file: 'README.md', commit: 'cfe9aacbc02528b' }
  #  end
  #end
end
