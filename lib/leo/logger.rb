module Leo
  class Logger
    def describe(header)
      width = 50
      log  "#" * width
      log header.center(width)
      log  "#" * width
    end

    def log(str)
      puts str
    end
  end
end
