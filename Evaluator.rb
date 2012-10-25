require 'set'

require 'nil/serialise'

require_relative 'DotaBuff'
require_relative 'Player'
require_relative 'HeroStatistics'

require_relative 'common'

class Evaluator
  def initialize(databasePath = 'players.db')
    @server = DotaBuff.new
    @minimumWeight = 0.2
    @maximumWeight = 1.0
    @minimumGameCount = 100
    @modifyOwnWeight = false
    @ownWeight = 1.0
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
    player = Player.new(id, wins, losses)
    return player
  end

  def evaluateMatch(matchId)
    return evaluateMatches([matchId])
  end

  def evaluateMatchPercentileRanges(matchIds)
    percentiles = []
    matchIds.each do |matchId|
      percentile = evaluateMatch(matchId)
      percentiles << percentile
      printPercentile(percentile)
    end
    puts percentiles.inspect
    puts "Percentile range: #{percentageString(percentiles.min)} - #{percentageString(percentiles.max)}"
  end

  def evaluateMatches(matchIds, playerId = nil)
    if playerId != nil
      thisPlayer = getStats(playerId)
    end
    players = {}
    collisions = Set.new
    matchIds.each do |matchId|
      matchPath = "/matches/#{matchId}"
      matchData = @server.download(matchPath)
      pattern = /<a href="\/players\/(\d+)"><img/
      matchData.scan(pattern) do |match|
        currentPlayerId = match[0].to_i
        if currentPlayerId == playerId
          next
        end
        if players.include?(currentPlayerId)
          if !collisions.include?(currentPlayerId)
            collisions.add(currentPlayerId)
          end
          next
        end
        players[currentPlayerId] = getStats(currentPlayerId)
      end
    end
    if playerId != nil && !@modifyOwnWeight
      players[playerId] = thisPlayer
    end
    weightedDifferences = players.map do |id, player|
      if player.games >= @minimumGameCount
        weight = @maximumWeight
      else
        weight = @minimumWeight + (1.0 - player.games.to_f / @minimumGameCount) * (@maximumWeight - @minimumWeight)
      end
      [weight, player.difference]
    end
    if playerId != nil && @modifyOwnWeight
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
    if playerId != nil && !collisions.empty?
      puts "Collisions: #{collisions.size}"
    end
    return percentile
  end

  def printPercentile(percentile, description = 'Percentile')
    puts "#{description}: #{percentageString(percentile)}"
  end

  def evaluatePlayer(id, accuracy)
    matchOverviewData = @server.download("/players/#{id}/matches")
    pattern = /<a href="\/matches\/(\d+)" class="hero-link">/
    accuracyCounter = 0
    matchIds = []
    matchOverviewData.scan(pattern) do |match|
      matchId = match[0]
      matchIds << matchId
      accuracyCounter += 1
      if accuracyCounter >= accuracy
        break
      end
    end
    percentile = evaluateMatches(matchIds, id)
    printPercentile(percentile)
  end
end
