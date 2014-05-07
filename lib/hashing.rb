require 'hashing/version'
require 'hashing/ivar'
require 'hashing/options'
require 'hashing/hasherizer'
require 'hasherize'

module Hashing
  # Inform the user about an attempt to create an instance, using a `Hash` with
  # keys that does not correspond to the mape made using `.hasherize`
  class UnconfiguredIvar < StandardError
    def initialize(ivar_name, class_name)
      super "The Hash has a :#{ivar_name} key, "+
        "but no @#{ivar_name} was configured in #{class_name}"
    end
  end

  # Inject the public api into the client class.
  #
  # @since 0.0.1
  #
  # @example including Hashing
  #   require 'hashing'
  #
  #   class File
  #     include Hashing
  #     hasherize :path, :commit
  #
  #     def initialize(path, commit)
  #       @path, @commit = path, commit
  #     end
  #   end
  #
  # When `Hashing` is included, the host class will gain the `.from_hash({})`
  # method and the `#to_h` instance method.
  # Another method that will be added is the private class method `.hasherize`
  # will be added so you can indicate what ivars do you want in your sarialized
  # objects.
  def self.included(client_class)
    client_class.extend Hasherizer
  end

  #
  # The `Hash` returned by `#to_h` will be formed by keys based on the ivars
  # names passed to `hasherize` method.
  #
  # @example File hahserized (which include `Hashing`)
  #
  #   file = File.new 'README.md', 'cfe9aacbc02528b'
  #   file.to_h
  #   # => { path: 'README.md', commit: 'cfe9aacbc02528b' }
  def to_h
    hash_pairs = self.class._ivars.map { |ivar|
      # use the @option.on[:collection] to solve this better
      value = instance_variable_get "@#{ivar}"
      construct_collection_metada value, ivar
      [ivar.to_sym, ivar.to_h(value)]
    }
    Hash[hash_pairs].merge(@_hashing_meta_data || {})
  end

  private

  def _meta_data(name, class_name)
    @_hashing_meta_data ||= { __hashing__: { types: {} } }
    @_hashing_meta_data[:__hashing__][:types][name] = class_name
    @_hashing_meta_data
  end

  def construct_collection_metada(value, ivar)
    if value.respond_to? :map
      _meta_data ivar.to_sym, value.first.class
    end
  end
end
