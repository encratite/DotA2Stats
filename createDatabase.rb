require 'nil/file'
require 'nil/serialise'

require_relative 'Player'

def createDatabase(databasePath)
  output = []
  puts 'Reading...'
  files = Nil.readDirectory('players')
  index = 1
  files.each do |file|
    data = Nil.readFile(file.path)
    if index % 100 == 0
      puts "#{index}/#{files.size} #{file.path}"
    end
    pattern = /<span class="won">(\d+)<\/span> - <span class="lost">(\d+)<\/span>/
    match = data.match(pattern)
    if match == nil
      next
    end
    wins = match[1].to_i
    losses = match[2].to_i
    player = Player.new(wins, losses)
    output << player
    index += 1
  end
  Nil.serialise(output, databasePath)
  puts output.size
end

createDatabase('players.db')
