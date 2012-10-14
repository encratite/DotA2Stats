require 'nil/http'

class DotaBuff
  def initialize
    @server = Nil::HTTP.new('dotabuff.com')
    @server.ssl = true
  end

  def download(path)
    puts "Downloading #{path}"
    contents = @server.get(path)
    if contents == nil
      raise "Unable to retrieve #{path}"
    end
    return contents
  end
end
