module Hashing
  # Represents each one of the instance variables in a class that should be used
  # to represent an object in a `Hash` form (serialization).
  class Ivar
    attr_reader :name

    # Configure the name of an `ivar` and the 'callable' objects thath will be
    # used to prepare the `ivar` value for serialization, and to load the object
    # from a `Hash`.
    #
    # @param name [Symbol] name of a class `ivar`
    # @param to_h [#call] callable to transform the value when serializing
    # @param from_hash [#call] callable to transform the value from a `Hash`
    def initialize(name, to_h = nil, from_hash = nil)
      @name = name.to_sym
      @to_h = to_h
      @from_hash = from_hash
    end

    # Processes the parameter acordingly to the configuration made in the
    # constructor. If some was made, return the value after being processed or
    # else return the value as it is.
    #
    # Also guarantee that if a value is a #map, every item with `Hashing` in his
    # method lookup will be sent the message `#to_h`.
    #
    # @param value [Object] object to be processed before being stored in a `Hash`
    # @return the value that will be stored in the `Hash`
    def to_h(value)
      return value unless @to_h

      if value.respond_to? :map
        value = hasherize value
      end
      @to_h.call value
    end

    # Processes the Object provinient from a `Hash` so it can be used to
    # reconstruct an instance.
    #
    # @param value [Object] object provinient from a hash
    # @return the value that will be used to reconstruct the original instance
    def from_hash(value, metadata = {})
      return value unless @from_hash

      if value.respond_to? :map
        value = normalize(value, metadata)
      end
      @from_hash.call value
    end

    def to_sym
      @name.to_sym
    end

    def to_s
      @name.to_s
    end

    private
    # Is an object descendent of {Hashing}?
    #
    # @param value [Object]
    def hashing?(value)
      value.class.ancestors.include? Hashing
    end

    # Hasherize a value when it has {Hashing} in it's method lookup or return
    # the value. Util when a collection of {Hashing} objects is given and need
    # to be "hasherized"
    #
    # @param value [#map] the value to be verified as a {Hashing} (or not)
    # @return [#map] collection of hashes
    def hasherize(collection)
      collection.map { |item| hashing?(item) ? item.to_h : item }
    end

    # If a collection of {Hashing} objects is given, we have to reconstruct all
    # collections members before while reconstructing the collection itself.
    # This method provides that
    #
    # TODO: (need?) recursion to reconstruct collections of collections
    #
    # @param value [#map] the collection of {Hashing} objects
    # @param metadata [Hash] containing serialized data about the original object
    # @return [#map] collection of {Hashing} instances
    def normalize(collection, metadata)
      elements_class = metadata.fetch(:types, {}).fetch(@name, nil)
      return collection unless elements_class.respond_to? :from_hash

      collection.map { |element| elements_class.from_hash element }
    end
  end
end
