require 'set'

require 'nil/serialise'

require_relative 'DotaBuff'
require_relative 'Player'

require_relative 'common'

class PlayerEvaluator
  def initialize(accuracy, databasePath)
    @server = DotaBuff.new
    @accuracy = accuracy
    @minimumWeight = 0.2
    @maximumWeight = 1.0
    @minimumGameCount = 100
    @modifyOwnWeight = false
    @ownWeight = 1.0 * @accuracy

    loadDatabase(databasePath)
  end

  def loadDatabase(databasePath)
    players = Nil.deserialise(databasePath)
    @differences = []
    players.each do |player|
      if player.games < @minimumGameCount
        next
      end
      @differences << player.difference
    end
    @differences.sort!
  end

  def getPercentile(playerDifference)
    c = 0
    while @differences[c] < playerDifference && c < @differences.size
      c += 1
    end
    if c == @differences.size
      raise 'WLD too high to be evaluated'
    end
    d = c
    while @differences[c] == @differences[d + 1] && d + 1 < @differences.size
      d += 1
    end
    b = [c - 1, 0].max
    a = b
    while a > 1 && @differences[a] == @differences[b]
      a -= 1
    end
    leftDifference = @differences[b]
    leftPercentile = (a + b).to_f / 2 / @differences.size
    rightDifference = @differences[c]
    rightPercentile = (c + d).to_f / 2 / @differences.size
    weight = (playerDifference - leftDifference) / (rightDifference - leftDifference)
    percentile = leftPercentile * weight + rightPercentile * (1 - weight)
    return percentile
  end

  def getStats(id)
    playerData = @server.download("/players/#{id}")
    pattern = /<span class="won">(\d+)<\/span> - <span class="lost">(\d+)<\/span>/
    match = playerData.match(pattern)
    if match == nil
      raise "Unable to detect wins/losses"
    end
    wins = match[1].to_i
    losses = match[2].to_i
    player = Player.new(wins, losses)
    return player
  end

  def evaluate(id)
    thisPlayer = getStats(id)
    matchOverviewData = @server.download("/players/#{id}/matches")
    pattern = /<a href="(\/matches\/\d+)" class="hero-link">/
    paths = []
    players = {}
    collisions = Set.new
    accuracyCounter = 0
    matchOverviewData.scan(pattern) do |match|
      matchPath = match[0]
      matchData = @server.download(matchPath)
      pattern = /<a href="\/players\/(\d+)"><img/
      matchData.scan(pattern) do |match|
        playerId = match[0].to_i
        if id == playerId
          next
        end
        if players.include?(playerId)
          if !collisions.include?(playerId)
            collisions.add(playerId)
          end
          next
        end
        players[playerId] = getStats(playerId)
      end
      accuracyCounter += 1
      if accuracyCounter >= @accuracy
        break
      end
    end
    if !@modifyOwnWeight
      players[id] = thisPlayer
    end
    weightedDifferences = players.map do |id, player|
      if player.games >= @minimumGameCount
        weight = @maximumWeight
      else
        weight = @minimumWeight + (1.0 - player.games.to_f / @minimumGameCount) * (@maximumWeight - @minimumWeight)
      end
      [weight, player.difference]
    end
    if @modifyOwnWeight
      weightedDifferences << [@ownWeight, thisPlayer.difference]
    end
    totalWeight = 0
    weightedDifferences.each do |weight, difference|
      totalWeight += weight
    end
    weightedDifference = 0
    weightedDifferences.each do |weight, difference|
      weightedDifference += weight.to_f / totalWeight * difference
    end
    percentile = getPercentile(weightedDifference)
    if !collisions.empty?
      puts "Collisions: #{collisions.size}"
    end
    puts "Percentile: #{percentageString(percentile)}"
  end
end

if ARGV.size < 1
  puts 'Usage:'
  puts '<DotaBuff player ID>'
end

id = ARGV[0].to_i
accuracy = 1
if ARGV.size > 1
  accuracy = ARGV[1].to_i
end

evaluator = PlayerEvaluator.new(accuracy, 'players.db')
evaluator.evaluate(id)
