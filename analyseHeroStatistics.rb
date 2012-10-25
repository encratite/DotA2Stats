require 'nil/serialise'

require_relative 'Player'
require_relative 'HeroStatistics'

players = Nil.deserialise('players.db')
players.reject! do |player|
  player.difference < 30
end
heroes = {}
players.each do |player|
  player.statistics.each do |hero|
    if heroes[hero.name] == nil
      heroes[hero.name] = hero
    else
      heroes[hero.name].add(hero)
    end
  end
end

heroes = heroes.values
heroes.sort! do |x, y|
  - (x.winRatio <=> y.winRatio)
end
heroes.each do |hero|
  percentage = sprintf('%.1f', hero.winRatio * 100)
  puts "#{hero.name}: #{hero.games} games, #{percentage}%"
end
