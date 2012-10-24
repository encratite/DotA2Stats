class Player
  attr_reader :id, :wins, :losses

  def initialize(id, wins, losses)
    @id = id
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
