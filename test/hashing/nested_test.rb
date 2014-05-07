describe Hashing do
  describe 'when one of the ivars is an `Array` of hasherized objects' do
    class HashingCollectionOwner
      attr_reader :file, :commit, :annotations
      include Hasherize.new :file, :commit, :annotations

      loading ->(hash) { new hash[:file], hash[:commit], hash[:annotations] }

      def initialize(file, commit, annotations)
        @file, @commit, @annotations = file, commit, annotations
      end
    end

    class HashingCollectionMember
      attr_reader :annotation
      include Hasherize.new :annotation,
        to: ->(value) { "--#{value}" },
        from: ->(value) { "#{value}--" }

      loading ->(hash) { new hash[:annotation] }

      def initialize(annotation)
        @annotation = annotation
      end
    end

    describe '#to_h' do
      it 'calls #to_h for each array item when hashifying the object' do
        owner = HashingCollectionOwner.new 'README.md', 'cfe9aacbc02528b', [
          HashingCollectionMember.new('first'),
          HashingCollectionMember.new('second'),
        ]
        owner.to_h.must_be :==, {
          file: 'README.md',
          commit: 'cfe9aacbc02528b',
          annotations: [
            { annotation: '--first' },
            { annotation: '--second' },
          ],
          __hashing__: {
            types: {
              annotations: HashingCollectionMember
            }
          }
        }
      end

      it "don't call the #to_h on inner object that don't include `Hashing`" do
        owner = HashingCollectionOwner.new 'README.md', 'cfe9aacbc02528b', [
          HashingCollectionMember.new('first'),
          "xpto",
        ]
        owner.to_h.must_be :==, {
          file: 'README.md',
          commit: 'cfe9aacbc02528b',
          annotations: [
            { annotation: '--first' },
            'xpto',
          ],
          __hashing__: {
            types: {
              annotations: HashingCollectionMember
            }
          }
        }
      end
    end

    describe '#from_h' do
      let(:hash_values) do
        {
          file: "README.md",
          commit: "cfe9aacbc02528b",
          annotations: [
            {annotation: "first"},
            {annotation: "second"}
          ],
          __hashing__: {
            types: {
              annotations: HashingCollectionMember
            }
          }
        }
      end

      it 'calls #from_h for each on an yaml array that contains hasherized objects' do
        owner = HashingCollectionOwner.from_hash hash_values
        owner.annotations.first.annotation.must_be :==, 'first--'
        owner.annotations.last.annotation.must_be :==, 'second--'
      end
    end
  end
end
