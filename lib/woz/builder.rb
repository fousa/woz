require "highline/import"
require "csv"

require "spreadsheet"
Spreadsheet.client_encoding = 'UTF-8'

module Woz
  class Builder
    KEY_COLUMN = "keys"

    class << self
      def init
        file = File.join(Dir.pwd, config_file_name)

        if File.exists?(file)
          warn "# '#{file}' already exists"
        elsif File.exists?(file.downcase)
          warn "# '#{file.downcase}' exists, which could conflict with `#{file}'"
        else
          puts "# writing '#{file}'"
          File.open(file, "w") { |f| f.write(instructions_text) }
        end
        puts "# woz initialized!"
      end

      def generate_csv
        generate_translation_csv
      end

      def generate_xls
        generate_translation_xls
      end

      def generate_strings(csv=false, filepath=nil)
        if csv
          generate_translation_strings_from_csv(filepath)
        else
          generate_translation_strings_from_xls(filepath)
        end
      end

      protected

      def config_file_name
        ".wozniak"
      end

      def instructions_text
    <<TEXT
# [Woz](http://github.com/fousa/woz)
# This file is used by Woz to make exporting to
# xls or strings even easier.
# 
# Woz.configure do |config|
#   config.xls_filename = "Localizations.xls"
#   config.csv_filename = "Localizations.csv"
#   config.strings_filename = "Localizations.strings"
#   config.ask_confirmation = false
# end
#
# You can now run `woz xls` to create a translation
# xls file.
TEXT
      end

      def get_output_dir name
        name = File.dirname(name)
        name = get_output_dir(name) if name.include? ".lproj"
        name
      end

      def parse_strings list, file
        fail "! strings file not found, specify the filename in the .wozniak file" unless File.exists?(File.join(file, Woz.config.strings_filename))

        language = get_language file
        puts "# parsing #{language}"
        File.open(File.join(file, Woz.config.strings_filename), "r").each do |row|
          if row.start_with? '"'
            if splitted = row.split(/"/, 5)
              if list[splitted[1]].nil?
                list[splitted[1]] = {}
              end
              list[splitted[1]][language] = splitted[3]
            end
          end
        end
      end

      def get_language name
        language = File.basename(name).gsub ".lproj", ""
        language
      end

      def generate_comma_seperated_values path, list
        CSV.open(path, "wb") do |csv|
          languages = list.values.map(&:keys).flatten.uniq
          csv << [KEY_COLUMN, languages].flatten
          list.each do |key, value|
            row = [key]
            languages.each do |language|
              row << list[key][language]
            end
            csv << row
          end
        end
      end

      def generate_spreadsheet list
        book  = Spreadsheet::Workbook.new
        sheet = book.create_worksheet

        languages = list.values.map(&:keys).flatten.uniq
        sheet.row(0).concat [KEY_COLUMN, languages].flatten

        index = 1
        list.each do |key, value|
          sheet.row(index).push key
          languages.each do |language|
            sheet.row(index).push list[key][language]
          end

          index += 1
        end

        book
      end

      def generate_translation(type=:xls)
        file = File.join(Dir.pwd, "en.lproj", Woz.config.strings_filename)
        output_dir = get_output_dir(file)
        list = {}
        Dir.foreach(output_dir) do |entry|
          parse_strings list, File.join(Dir.pwd, entry) if entry.include? ".lproj"
        end

        filename = Woz.config.send("#{type.to_s}_filename")
        if !Woz.config.ask_confirmation || !File.exists?(filename) || ask("! the project's #{type.to_s} file will be overwritten, type 'y' and enter to continue: ") == "y"
          if type == :xls
            content = generate_spreadsheet list
            content.write(File.join(output_dir, filename))
          else
            generate_comma_seperated_values File.join(output_dir, filename), list
          end
          puts "# #{type.to_s} generated at #{File.join(output_dir, filename)}"
        else
          puts "! #{type.to_s} generation canceled"
        end
      end

      def generate_translation_csv
        generate_translation(:csv)
      end

      def generate_translation_xls
        generate_translation(:xls)
      end

      def parse_xls file
        book  = Spreadsheet.open file
        sheet = book.worksheet 0

        languages = sheet.row(0).select { |i| i != KEY_COLUMN && i != "" }

        list = languages.inject({}) do |hash, language| 
          hash[language] = {}
          hash
        end

        sheet.each_with_index do |row, i|
          next if i == 0

          languages.each_with_index do |language, e|
            list[language][row[0]] = row[e+1]
          end
        end
        list
      end

      def parse_csv filepath
        index = 0
        languages = []
        list = {}
        CSV.foreach(filepath) do |row|
          if index == 0
            languages = row.select { |i| i != KEY_COLUMN && i != "" }
            list = languages.inject({}) do |hash, language| 
              hash[language] = {}
              hash
            end
          else
            languages.each_with_index do |language, e|
              list[language][row[0]] = row[e+1]
            end

          end
          index += 1
        end
        list
      end

      def generate_translation_strings_from_xls(xls_filepath=nil)
        filepath = File.expand_path(xls_filepath || Woz.config.xls_filename)
        file = File.join(filepath)

        fail "! xls file not found, specify the filename in the .wozniak file" unless File.exists?(file)

        list = parse_xls file
        generate_translation_strings(list)
      end

      def generate_translation_strings_from_csv(csv_filepath=nil)
        filepath = File.expand_path(csv_filepath || Woz.config.csv_filename)
        file = File.join(filepath)

        fail "! csv file not found, specify the filename in the .wozniak file" unless File.exists?(file)

        list = parse_csv filepath
        generate_translation_strings(list)
      end

      def generate_translation_strings(list)
        output_dir = get_output_dir(File.join(File.expand_path(Woz.config.xls_filename)))
        cocoa_array = "#define kLanguages [NSArray arrayWithObjects:"
        cocoa_languages_array = []
        list.keys.compact.each do |language|
          puts "# parsing #{language}"
          proj_dir = File.join(output_dir, "#{language}.lproj")
          Dir.mkdir(proj_dir) unless File.directory?(proj_dir)

          file_path = File.join(proj_dir, Woz.config.strings_filename)
          cocoa_languages_array << "@\"#{language}\""

          new_file = !File.exists?(file_path)
          if new_file || !Woz.config.ask_confirmation || ask("! the project's #{language} strings file will be overwritten, type 'y' and enter to continue: ") == "y"
            if new_file
              file = File.new(file_path, "w")
            else
              file = File.open(file_path, "w")
            end
            list[language].each do |key, value|
              unless key.nil?
                file.puts "\/\* #{key} \*\/"
                if value.nil?
                  file.puts "\"#{key}\" = \"MISSING VALUE\";"
                else
                  file.puts "\"#{key}\" = \"#{value}\";"
                end
                file.puts ""
              end
            end
            puts "# #{language} strings generated at #{file_path}"
          else
            puts "! #{language} strings generation canceled"
          end
        end
        cocoa_languages_array << "nil"
        cocoa_array << "#{cocoa_languages_array.join(', ')}]"
        cocoa_array
      end
    end
  end
end





