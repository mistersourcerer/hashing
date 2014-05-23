module Hashing
  # Represents an ivar in a class that includes {Hashing} which contains a
  # collection of other {Hashing} instances.
  class IvarCollection
    extend Forwardable
    def_delegators :@holder, :to_sym, :to_s, :name, :to_h=, :from_hash=

    def initialize(collection_holder_ivar, type)
      @holder = collection_holder_ivar
      @type = type
    end

    def to_h(value)
      @holder.to_h value.map { |item|
        item.respond_to?(:to_h) ? item.to_h : item
      }
    end

    def from_hash(value)
      @holder.from_hash value.map { |item| @type.from_hash item }
    end
  end
end
