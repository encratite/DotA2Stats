require 'nil/file'

require_relative 'DotaBuff'

class MatchDownloader
  def initialize
    @server = DotaBuff.new
  end

  def processMatchPage(pageData)
    foundOne = false
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
      foundOne = true
    end
    return foundOne
  end

  def downloadMatches(firstPage = 1, lastPage = 20)
    page = firstPage
    while page <= lastPage
      pageData = @server.download("/matches?page=#{page}")
      foundOne = processMatchPage(pageData)
      if !foundOne
        return
      end
      page += 1
    end
  end
end

downloader = MatchDownloader.new
while true
  puts 'Running'
  downloader.downloadMatches
  puts 'Waiting'
  sleep(60)
end
