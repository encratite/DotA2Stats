class HeroStatistics
  attr_reader :name, :wins, :losses

  def initialize(name, wins, losses)
    @name = name
    @wins = wins
    @losses = losses
  end

  def add(hero)
    @wins += hero.wins
    @losses += hero.losses
  end

  def games
    return @wins + @losses
  end

  def winRatio
    return @wins.to_f / games
  end
end
