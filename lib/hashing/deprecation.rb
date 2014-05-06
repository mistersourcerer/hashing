module Hashing
  class Deprecation
    attr_reader :method, :replacement, :version

    def initialize(method, replacement, version = nil)
      @method, @replacement, @version = method, replacement, version
    end

    def warn(caller_first_line)
      called_from = caller_first_line.gsub /:in(.*)/, ""
      Object.send :warn, deprecation_message(called_from)
    end

    private

    def deprecation_message(called_from)
      ["NOTE: `.hasherize' option :#{@method} is deprecated; ",
        "use :#{@replacement} instead. ",
        "It will be removed on or after version #{@version} ",
        "`.hasherize ..., :#{@method}' called from #{called_from}"].join
    end
  end
end
