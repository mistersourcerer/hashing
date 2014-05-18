require 'hashing'

# Provides some sugar syntax to declare which `ivars` should be used to
# represent an object as a `Hash`.
#
# It respects all the behavior you will get by including {Hashing}. In fact,
# using this constructor is a shortcut to `include Hashing`, and call
# `.hasherize`
#
# @since 0.0.1
#
# @example shortcut to `include Hashing` and call `.hasherize`
#   class File
#     include Hasherize.new :path, :commit
#   end
#
# @example configuring :to_hash and :from_hash strategies
#   class File
#     include Hasherize.new :content,
#       to_hash: ->(content) { Base64.encode64 content },
#       from_hash: ->(content_string) { Base64.decode64 content_string }
#   end
class Hasherize < Module

  # Stores the ivars and options to be repassed to `Hashing.serialize` by the
  # hook {#included}
  #
  # @param ivars_and_options [*args] ivar names and options (`:to_hash` and `:from_hash`)
  def initialize(*ivars)
  end

  # Includes the `Hashing` module and calls {Hashing.hasherize}, repassing the
  # ivar names an the options received in the constructor
  def included(serializable_class)
    serializable_class.module_eval do
      include Hashing
    end
    serializable_class.send :hasherize, *@ivars
  end
end
