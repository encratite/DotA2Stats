require 'nil/file'

require_relative 'DotaBuff'

class PlayerDownloader
  def initialize
    @server = DotaBuff.new
  end

  def downloadPlayers
    files = Nil.readDirectory('matches')
    files.each do |file|
      data = Nil.readFile(file.path)
      pattern = /<div class="image-container image-container-smallicon image-container-player"><a href="\/players\/(\d+)">/
      data.scan(pattern) do |match|
        id = match[0]
        httpPath = "/players/#{id}"
        filePath = "players/#{id}"
        if File.exists?(filePath)
          next
        end
        playerData = @server.download(httpPath)
        Nil.writeFile(filePath, playerData)
      end
    end
  end
end

downloader = PlayerDownloader.new
while true
  downloader.downloadPlayers
end
