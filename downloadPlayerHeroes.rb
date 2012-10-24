require 'nil/file'
require 'nil/serialise'

require_relative 'DotaBuff'
require_relative 'Player'

players = Nil.deserialise('players.db')
server = DotaBuff.new

minimumGames = 100
minimumDifference = 20

filteredPlayers = players.reject do |player|
  player.games < minimumGames || player.difference < minimumDifference
end

counter = 0

players.each do |player|
  path = "/players/#{player.id}/heroes"
  outputPath = "playerHeroes/#{player.id}"
  counter += 1
  if File.exists?(outputPath)
    next
  end
  puts "(#{counter}/#{filteredPlayers.size}) #{path}"
  data = server.download(path)
  Nil.writeFile(outputPath, data)
end
