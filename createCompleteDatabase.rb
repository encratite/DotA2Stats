require 'nil/file'
require 'nil/serialise'

require_relative 'Player'
require_relative 'HeroStatistics'

class DatabaseCreator
  def initialize(incompleteDatabasePath)
    @incompletePlayers = Nil.deserialise(incompleteDatabasePath)
    @completePlayers = []
  end

  def getPlayer(id)
    @incompletePlayers.each do |player|
      if player.id == id
        return player
      end
    end
    raise "Unable to find player with ID #{id}"
  end

  def processHeroData(id, data)
    player = getPlayer(id)
    pattern = /<img alt="(.+?)" class="image-icon image-hero".+?<div>(\d+)<\/div>.+?<div>(\d+\.\d+)%<\/div>/
    data.scan(pattern) do |match|
      hero = fixHeroName(match[0])
      games = match[1].to_i
      winRatio = match[2].to_f / 100
      wins = (games * winRatio).round
      losses = games - wins
      statistics = HeroStatistics.new(hero, wins, losses)
      player.addHeroStatistics(statistics)
    end
    @completePlayers << player
  end

  def readHeroData
    files = Nil.readDirectory('playerHeroes')
    counter = 1
    files.each do |file|
      id = file.name.to_i
      if counter % 1000 == 0
        puts "Processing #{file.path}"
      end
      data = Nil.readFile(file.path)
      processHeroData(id, data)
      counter += 1
    end
  end

  def createDatabase(path)
    Nil.serialise(@completePlayers, path)
  end

  def fixHeroName(name)
    if name == 'Magnataur'
      return 'Magnus'
    end
    return name.gsub('&#x27;', "'")
  end
end

creator = DatabaseCreator.new('playersIncomplete.db')
creator.readHeroData
creator.createDatabase('players.db')
