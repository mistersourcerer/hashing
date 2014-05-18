require 'hashing/version'
require 'hashing/ivar'
require 'hashing/hasherizer'
require 'hasherize'

module Hashing
  # Inform the user about an attempt to create an instance, using a `Hash` with
  # keys that does not correspond to the mape made using `.hasherize`
  class UnconfiguredIvar < StandardError
    def initialize(ivar_names, class_name)
      super [
        "The hash passed to #{class_name}.from_hash has the following ",
        "keys that aren't configured by the .hasherize method: ",
        "#{ivar_names.join ","}."
      ].join
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
    self.class.__hasher.to_h self
  end
end
