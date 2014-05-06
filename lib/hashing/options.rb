require 'hashing/deprecation'
module Hashing
  # Stores the options passed to a `.hasherize` invocation.
  # Also filters options that are not recognizable and shows deprecation
  # warnings when necessary.
  #
  # @example Filtering deprecated and unrecognized options
  #   options = Options.new to_hash: ->(my_value){}, xpto:  "I'm a bogus option"
  #   options.filter("some_ruby_file.rb:13")
  #   # => warn: 'Note. `.hasherize' option :to_hash is deprecated...'
  #   # => warn: 'There is no option :xpto for `.hasherize', it will be ignored...'
  #
  #   options.strategies[:to]
  #   # => ->(my_value){}
  #
  # So an {Options} instance provides access to the options with deprecations
  # already replaced by their replacement. The `#filter` method will use
  # `warn` to show the user all notices about deprecations and invalid options
  class Options
    DEPRECATIONS = {
      to_hash: Deprecation.new(:to_hash, :to, "v1.0.0"),
      from_hash: Deprecation.new(:from_hash, :from, "v1.0.0"),
    }

    RECOGNIZED = [:to, :from] # %i(to, from) =(

    # @param all_options [Hash] options passed to a `.hasherize` invocation
    def initialize(all_options)
      @options = all_options
    end

    # Return a ready to use {Options} instance, change the state of the
    # current instance to use only recognized and current options.
    # Warns the user about deprecations and unreconized options.
    #
    # @param called_from [String] information about where the `.hasherize` invocation took place
    # @return [Options] ready to be used
    def filter(called_from)
      alert_for_deprecations called_from
      alert_for_unrecognized called_from
      self
    end

    def strategies
      @strategies ||= {
        to: @options.fetch(:to, ->(value) { value }),
        from: @options.fetch(:from, ->(value) { value })
      }
    end

    private

    # Show deprecation warnings for all deprecations indicated in the
    # `.DEPRECATIONS` constant.
    #
    # @param called_from [String] information about where the `.hasherize` invocation took place
    def alert_for_deprecations(called_from)
      DEPRECATIONS.keys.each do |deprecated|
        if @options.has_key? deprecated
          DEPRECATIONS[deprecated].warn called_from
          value = @options.delete deprecated
          @options[ DEPRECATIONS[deprecated].replacement ] = value
        end
      end
    end

    def alert_for_unrecognized(called_from)
      unrecognized_options = @options.keys - RECOGNIZED
      unrecognized_options.each do |option|
        warn ["NOTE: `.hasherize' was invoked with unrecognized ",
              ":#{option} option. It will be ignored."].join
        @options.delete option
      end
    end
  end
end
