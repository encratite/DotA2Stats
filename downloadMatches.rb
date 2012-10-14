require 'nil/file'

require_relative 'DotaBuff'

class MatchDownloader
  def initialize
    @server = DotaBuff.new
  end

  def processMatchPage(pageData)
    pattern = /<a href="(\/matches\/\d+)">(\d+)<\/a>/
    pageData.scan(pattern) do |match|
      httpPath = match[0]
      id = match[1]
      filePath = "matches/#{id}"
      if File.exists?(filePath)
        next
      end
      matchData = @server.download(httpPath)
      Nil.writeFile(filePath, matchData)
    end
  end

  def downloadMatches(firstPage = 1, lastPage = 20)
    page = firstPage
    while page <= lastPage
      pageData = @server.download("/matches?page=#{page}")
      processMatchPage(pageData)
      page += 1
    end
  end
end

downloader = MatchDownloader.new
while true
  downloader.downloadMatches
  sleep(60)
end
