module BuildComms
  module Utils
    def Utils.string_or_default(str, default)
      (str.nil? or str.empty?) ? default : str
    end
  end
end
