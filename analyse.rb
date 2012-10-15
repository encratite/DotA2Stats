require 'nil/serialise'

require_relative 'Player'
require_relative 'common'

def properMedian(input)
  if input.size == 1
    return input[0]
  end
  half = input.size / 2
  if input.size % 2
    return input[half]
  else
    return (input[half] + input[half + 1]).to_f / 2
  end
end

def median(input)
  return input[input.size % 2]
end

def quantile(input, quantile)
  index = (input.size * quantile).to_i
  return input[index]
end

def analyse(databasePath)
  cutOff = 100
  players = Nil.deserialise(databasePath)
  sumGames = 0
  gameCounts = []
  differences = []
  playersUsed = 0
  players.each do |player|
    games = player.wins + player.losses
    if games < cutOff
      next
    end
    sumGames += games
    difference = player.wins - player.losses
    gameCounts << games
    differences << difference
    playersUsed += 1
  end
  puts "Minimum number of games required: #{cutOff}"
  puts "Players with the required number of games: #{percentage(playersUsed, players.size)}"
  gameCounts.sort!
  meanGames = sumGames.to_f / players.size
  medianGames = median(gameCounts)
  puts "Average number of games per player (arithmetic mean): #{floatString(meanGames)}"
  puts "Average number of games per player (median): #{medianGames}"
  differences.sort!
  puts "Win/loss difference brackets:"
  quantileStep = 5
  currentQuantile = quantileStep
  while currentQuantile < 100
    value = quantile(differences, currentQuantile.to_f / 100)
    puts "#{currentQuantile}%: #{value}"
    currentQuantile += quantileStep
  end
end

analyse('players.db')
