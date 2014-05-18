module Hashing
  # Inform the user about an attempt to create an instance, using a `Hash` with
  # keys that does not correspond to the mape made using `.hasherize`
  class UnconfiguredIvarError < StandardError
    def initialize(ivar_names, class_name)
      super [
        "The hash passed to #{class_name}.from_hash has the following ",
        "keys that aren't configured by the .hasherize method: ",
        "#{ivar_names.join ","}."
      ].join
    end
  end
end
