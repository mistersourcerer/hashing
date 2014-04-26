require "hashing/version"

module Hashing
  def self.included(client_class)
    client_class.extend Hasherizer
  end

  module Hasherizer
    def hasherize(*ivars)

    end
  end
end
