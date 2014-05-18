require "optioning"

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

    def add(ivar_names)
      ivar_names = Array(ivar_names)
      @current_ivars = ivar_names.map { |ivar| Ivar.new ivar }
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
    # @return void
    def loading(block)
      @loading = block
      self
    end

    def load(hash)
      check_for_unconfigured_keys hash
      loader = @loading || ->(serialized) { @host_class.new serialized }
      loader.call hash
    end

    def to_h(instance)
      pairs = @ivars.map { |ivar|
        ivar_value = instance.send :instance_variable_get, :"@#{ivar.to_sym}"
        [ivar.to_sym, ivar.to_h(ivar_value)]
      }
      Hash[pairs]
    end

    private
    def check_for_unconfigured_keys(hash)
      unrecognized_keys = hash.keys - @ivars.map(&:to_sym)
      if unrecognized_keys.count > 0
        raise Hashing::UnconfiguredIvar.new unrecognized_keys, @host_class
      end
    end
  end

  # Define the class methods that should be available in a 'hasherized ®' class
  # (a class that include `Hashing`).
  module Hasherizer
    # Configures which instance variables will be used to compose the `Hash`
    # generated by `#to_h`
    #
    # @api
    # @param ivars [Array<Symbol>]
    def hasherize(*ivars)
      __hasher.add ivars
    end

    # those methods are private but part of the class api (macros).
    # #TODO: there is a way to document the 'macros' for a class in YARD?
    private :hasherize

    # Receives a `Hash` and uses the strategy configured by `.loading` to
    # (re)create an instance of the 'hasherized ®' class.
    #
    # @param pairs [Hash] in a valid form defined by `.hasherize`
    # @return new object
    def from_hash(hash)
      __hasher.load hash
    end

    def __hasher
      @__hasher ||= Hasher.new self
    end
  end
end
