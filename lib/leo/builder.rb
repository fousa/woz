require "spreadsheet"
Spreadsheet.client_encoding = 'UTF-8'

module Leo
  class Builder
    KEY_COLUMN = "keys"

    class << self
      def init
        file = File.join(Dir.pwd, config_file_name)

        if File.exists?(file)
          warn "[skip] '#{file}' already exists"
        elsif File.exists?(file.downcase)
          warn "[skip] '#{file.downcase}' exists, which could conflict with `#{file}'"
        else
          puts "[add] writing '#{file}'"
          File.open(file, "w") { |f| f.write(instructions_text) }
        end
        puts "[done] leo initialized!"
      end

      def generate_xls
        generate_translation_xls
      end

      protected

      def config_file_name
        ".leorc"
      end

      def instructions_text
    <<TEXT
# [Leo](http://github.com/fousa/leo)
# This file is used by Leo to make exporting to
# xls or strings even easier.
# 
# Leo.configure do |config|
#   config.xls_name = "Localizations.xls"
#   config.strings_name = "Localizations.strings"
# end
#
# You can now run `leo xls` to create a translation
# xls file.
TEXT
      end

      def get_output_dir name
        name = File.dirname(name)
        name = get_output_dir(name) if name.include? ".lproj"
        name
      end

      def parse_strings list, file
        language = get_language file
        puts "# Parsing #{language}"
        File.open(File.join(file, Leo.config.strings_name), "r").each do |row|
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

      def generate_translation_xls
        file = File.join(Dir.pwd, "en.lproj", Leo.config.strings_name)
        output_dir = get_output_dir(file)
        list = {}
        Dir.foreach(output_dir) do |entry|
          parse_strings list, File.join(Dir.pwd, entry) if entry.include? ".lproj"
        end

        xls = generate_spreadsheet list
        xls.write(File.join(output_dir, Leo.config.xls_name))
        puts "# XLS generated at #{File.join(output_dir, Leo.config.xls_name)}"
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

      def generate_strings_files file
        output_dir = get_output_dir File.absolute_path(ARGV.first)
        puts "--- Output directory set to #{output_dir}"

        xls_filename = File.basename(ARGV.first)
        puts "--- XLS filename set to #{xls_filename}"

        puts "--- Parse xls"
        list = parse_xls xls_filename

        cocoa_array = "#define kLanguages [NSArray arrayWithObjects:"
    # @"en", @"bg", @"th", @"br", @"da", @"fi", @"no", @"sv", @"grk", @"fr", @"it", @"pt", @"de", @"ro", @"hu", @"cs", @"sk", @"pl", @"es", @"ru", @"cn", @"za", @"nl", nil]
    cocoa_languages_array = []
    list.keys.each do |language|
      proj_dir = "#{output_dir}/#{language}.lproj"
      Dir.mkdir(proj_dir) unless File.directory?(proj_dir)

      file_path = "#{proj_dir}/#{xls_filename.gsub(".xls", "")}.strings"
      cocoa_languages_array << "@\"#{language}\""
      puts "--- Write to #{file_path}"

      if File.exists?(file_path)
        file = File.open(file_path, "w")
      else
        file = File.new(file_path, "w")
      end
      list[language].each do |key, value|
        if value.nil?
          file.puts "\"#{key}\" = \"MISSING VALUE\";" unless key.nil?
        else
          file.puts "\"#{key}\" = \"#{value}\";"
        end
      end
    end
    cocoa_languages_array << "nil"
    cocoa_array << "#{cocoa_languages_array.join(', ')}]"
    puts cocoa_array
  end
end
end
end





