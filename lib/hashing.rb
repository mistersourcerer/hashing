require 'hashing/macros'

module Hashing

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
    client_class.extend Macros
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
