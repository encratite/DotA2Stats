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
  cutoff = 100
  players = Nil.deserialise(databasePath)
  sumGames = 0
  gameCounts = []
  differences = []
  playersUsed = 0
  players.each do |player|
    games = player.wins + player.losses
    if games < cutoff
      next
    end
    sumGames += games
    difference = player.wins - player.losses
    gameCounts << games
    differences << difference
    playersUsed += 1
  end
  puts "Minimum number of games required: #{cutoff}"
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

  graphCutoffs = [10, 50, 100]
  graphs = []
  graphCutoffs.each do |cutoff|
    graphs[cutoff] = {}
  end
  players.each do |player|
    graphs.each do |cutoff, data|
      if player.games < cutoff
        next
      end
      if data[difference] == nil
        data[difference] = 0
      end
      data[difference] += 1
    end
  end
  allData = {}
  graphs.each do |cutoff, data|
    data.each do |difference, count|
      if allData[difference] == nil
        allData[difference] = []
      end
    end
  end
  csv = csv.join("\n")
  Nil.writeFile("winLossDifference.csv", csv)
end

analyse('players.db')
