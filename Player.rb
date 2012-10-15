class Player
  attr_reader :wins, :losses

  def initialize(wins, losses)
    @wins = wins
    @losses = losses
  end
end
