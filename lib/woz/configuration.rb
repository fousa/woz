require "ostruct"

module Woz
  class Configuration < OpenStruct
    def self.default
      new \
      :xls_filename => "Localizations.xls",
      :strings_filename => "Localizations.strings",
      :ask_confirmation => false
    end
  end
end
