require "hashing/ivar"
require "hashing/unconfigured_ivar_error"

module Hashing
  class Hasher
    attr_reader :ivars

    def initialize(host_class, ivars = nil)
      @host_class = host_class
      add ivars
    end

    def to(block)
      @current_ivars.each { |ivar| ivar.to_h = block }
      self
    end

    def from(block)
      @current_ivars.each { |ivar| ivar.from_hash = block }
      self
    end

    def collection(type)
      # replace current ivar for it's collection...
      collections = @current_ivars.map { |ivar| IvarCollection.new ivar, type }
      @current_ivars.each { |ivar| @ivars.delete ivar }
      @ivars += collections
      self
    end

    def add(ivar_names)
      ivar_names = Array(ivar_names)
      @current_ivars = ivar_names.map { |ivar_name| Ivar.new ivar_name }
      @ivars ||= []
      @ivars += @current_ivars
      self
    end

    # Configures the strategy to (re)create an instance of the 'hasherized ®'
    # class based on a `Hash` instance. This strategy will be used by the
    # `.from_hash({})` method.
    #
    # This configuration is optional, if it's not called, then the strategy will
    # be just repassing the `Hash` to the initializer.
    #
    # @param strategy [#call]
    # @return [Hasher] (fluent interface)
    def loading(block)
      @loading = block
      self
    end

    def load(hash)
      check_for_unconfigured_keys hash
      loader = @loading || ->(serialized) { @host_class.new serialized }
      loader.call process_hash_values hash
    end

    def to_h(instance)
      pairs = @ivars.map { |ivar|
        ivar_value = instance.instance_variable_get :"@#{ivar.to_sym}"
        [ivar.to_sym, ivar.to_h(ivar_value)]
      }
      Hash[pairs]
    end

    private
    def check_for_unconfigured_keys(hash)
      unrecognized_keys = hash.keys - @ivars.map(&:to_sym)
      if unrecognized_keys.count > 0
        raise Hashing::UnconfiguredIvarError.new unrecognized_keys, @host_class
      end
    end

    def process_hash_values(hash)
      transformed_hash = @ivars.map { |ivar|
        [ivar.to_sym, ivar.from_hash(hash[ivar.to_sym])]
      }
      Hash[transformed_hash]
    end
  end
end
