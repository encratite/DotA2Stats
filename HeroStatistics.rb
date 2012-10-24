class HeroStatistics
  attr_reader :name, :wins, :losses

  def initialize(name, wins, losses)
    @name = name
    @wins = wins
    @losses = losses
  end
end
