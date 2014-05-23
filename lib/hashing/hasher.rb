require "hashing/ivar"
require "hashing/unconfigured_ivar_error"

module Hashing
  # This class contains the interface "exported" by a call to the `.hasherize`
  # method in any class that includes the module [Hashing].
  class Hasher
    attr_reader :ivars

    # @param host_class [Class] the class whose ivars will be used to serialize
    # @param ivars [Array<Symbol>] the ivars that will be serialized
    def initialize(host_class, ivars = nil)
      @host_class = host_class
      add ivars
    end

    # --- api {{{

    # Provides the api to configure the strategy to serialize an instance of a
    # class that includes {Hashing} into a hash object.
    #
    # @since 0.1.0
    #
    # @param strategy [#call] the logic to convert some value to a [Hash]
    # @return [Hasher]
    def to(strategy)
      logic_for :to_h, strategy
    end

    # Provides the api to configure the logic to serialize an instance of a
    # class that includes {Hashing} into a hash object.
    #
    # @since 0.1.0
    #
    # @param strategy [#call] the logic to convert some value to a [Hash]
    # @return [Hasher]
    def from(strategy)
      logic_for :from_hash, strategy
    end

    # Provides the api to create attr_readers in the host class for the current
    # configured ivars (those passed to {#add}).
    #
    # @since 0.1.0
    #
    # @example: creating attr_reader from :path and :commit
    #   hasherize(:path, :commit).reader true
    #
    # The example above will create accessors for :path and :commit
    #
    # @return [Hasher]
    def reader(should_create_attr_reader = true)
      if should_create_attr_reader
        @current_ivars.each { |ivar| @host_class.send :attr_reader, ivar.to_sym }
      end
      self
    end

    # Provides the api to indicate an object with the serialization and
    # unserialization logic.
    #
    # @example: using Base64 to serialize and unserialize some ivar:
    #   hahserize(:content).unsing(Base64).to(:encode64).from(:decode64)
    #
    # Note: any object can be passe to {#using}, and the methods in these object
    # passed as arguments to {#to} and {#from} need to be public.
    #
    # @since 0.1.0
    #
    # @return [Hasher]
    def using(serializator)
      @serializator = serializator
      self
    end

    # Provides the api to say if an ivar is a collection (#map) of instances of
    # a class that includes {Hashing}.
    # The idea here is just to be able to restore nested {Hashing} objects.
    #
    # @since 0.1.0
    #
    # @return [Hasher]
    def collection(type)
      # replace current ivar for it's collection version...
      collections = @current_ivars.map { |ivar| IvarCollection.new ivar, type }
      @current_ivars.each { |ivar| @ivars.delete ivar }
      @ivars += collections
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
    def loading(strategy)
      @loading = strategy
      self
    end

    # }}} api

    # This method can be called to define which ivars will be used as keys in
    # the final hash.
    # Ivar names passed as arguments to this method will be used to create
    # instances of [Ivar]. Those have the real logic of serialization and
    # unserialization of an [Ivar].
    # This method also keeps a reference to the last ivars passed as parameter.
    # This is necessary to allow us to do the following call:
    #
    #   hasherize(:ivar1, :ivar2).to(->(value){})
    #
    # The previous call will configure the `:to` strategy for `:ivar1` and
    # `:ivar2`.
    #
    # @param ivar_names [Array<Symbol>] ivars to be used to hasherize the instance
    # @return [Hasher]
    def add(ivar_names)
      ivar_names = Array(ivar_names)
      @current_ivars = ivar_names.map { |ivar_name| Ivar.new ivar_name }
      @ivars ||= []
      @ivars += @current_ivars
      self
    end

    # Provides the logic to transform an instance of a {Hashing} class into an
    # hash object.
    #
    # @return [Hash] a new hash in which keys are the ivar names and values the string value for those ivars.
    def to_h(instance)
      pairs = @ivars.map { |ivar|
        ivar_value = instance.instance_variable_get :"@#{ivar.to_sym}"
        [ivar.to_sym, ivar.to_h(ivar_value)]
      }
      Hash[pairs]
    end

    # This method will be called to reconstruct an instance of the type which
    # includes {Hashing}.
    # The `loader` in which `#call` will be called here is the one passed to the
    # {Hashing::Hasher#loading}. If none was passed, this method will just call
    # `.new` in the host class passing the [Hash] as argument.
    #
    # @param [Hash] hash serialized by a call to {Hashing::Hasher#to_h}
    def load(hash)
      check_for_unconfigured_keys hash
      loader = @loading || ->(serialized) { @host_class.new serialized }
      loader.call process_hash_values hash
    end

    private

    # @since 0.1.0
    #
    # @param way [Symbol] :from_hash or :to_h strategy
    # @param strategy [#call] the strategy to convert some value to or from a [Hash]
    # @return [Hasher]
    def logic_for(way, strategy)
      if @serializator
        strategy = @serializator.method strategy
      end
      @current_ivars.each { |ivar| ivar.send :"#{way}=", strategy }
      self
    end

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
