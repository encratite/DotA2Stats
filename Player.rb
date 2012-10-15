class Player
  attr_reader :wins, :losses

  def initialize(wins, losses)
    @wins = wins
    @losses = losses
  end

  def games
    return @wins + @losses
  end

  def difference
    return @wins - @losses
  end
end
