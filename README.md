# Woz

Generate your 'strings' files from an existing 'xls' file so your clients can translate their application by just entering all the value in the xls file. Of course woz will make sure you're able to generate the xls file from the existing strings file.

## Installation

Install the gem yourself:

    $ gem install woz

## Setup

Generate a configuration file if your not planning to go by the default values:

    woz setup

This will generate a '.wozniak' file in your project directory. This file contains the default values, and you can change them according to your needs.

## Generate csv

When you want to generate an csv file from your existing 'strings' files you just have to enter the following command:

    woz csv

Make sure that all the '.lproj' directories are in this directory and that the 'strings' file you specified in the '.wozniak' configuration are inside these '.lproj' directories.

This will generate 1 'csv' file inside this direcory and here you can check out all the used translations.

## Generate xls

When you want to generate an xls file from your existing 'strings' files you just have to enter the following command:

    woz xls

Make sure that all the '.lproj' directories are in this directory and that the 'strings' file you specified in the '.wozniak' configuration are inside these '.lproj' directories.

This will generate 1 'xls' file inside this direcory and here you can check out all the used translations.

## Generate strings

When you want to do the opposite, that is generate your strings file from an xls file, than you'll just have to run this command:

    woz strings

Make sure the xls in this directory, and that it has the following columns:
    
    keys (this it the column that defines the key)
    nl (the first language with the different strings, in this case Dutch)
    en (or English)
    fr (or even French)

To make it even more clear, here is a simple representation of the xls file:

    keys    nl      fr      en
    title   Titel   Titre   Title
    name    Name    Nom     Name

This will genereate different '.lproj' directories with the localized files inside of them.

There is also a possibility to generate strings files from a xls file located on a different location on your disk. Just pass the relative or absolute filepath to the 'woz strings' command:

    woz strings a_relative_directory/the_file.xls
    woz strings /an_absolute_directory/the_file.xls
    woz strings ~/an_absolute_directory_inside_your_home_folder/the_file.xls

## Changelog

### 0.2.0

- Add filename/filepath behind the 'woz strings' command in order to use that xls file for strings generation.
- Better .strings content formatting.
- Better overwrite confirmation messages.

## License

Check out the LICENSE.txt file. Really awesome reading material...

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
