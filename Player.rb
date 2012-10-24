class Player
  attr_reader :id, :wins, :losses, :statistics

  def initialize(id, wins, losses)
    @id = id
    @wins = wins
    @losses = losses
    @statistics = []
  end

  def games
    return @wins + @losses
  end

  def difference
    return @wins - @losses
  end

  def addHeroStatistics(heroStatistics)
    if @statistics == nil
      @statistics = []
    end
    @statistics << heroStatistics
  end
end
