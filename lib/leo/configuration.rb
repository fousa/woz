require "ostruct"

module Leo
  class Configuration < OpenStruct
    def self.default
      new \
      :xls_name => "Localizations.xls",
      :strings_name => "Localizations.strings",
      :ask_confirmation => false
    end
  end
end
