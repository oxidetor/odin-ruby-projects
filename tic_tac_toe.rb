class Cell
  @value = nil

  def value=(new_value)
    @value ||= new_value
  end
end

class Player
  def initialize(player_number)
    @player_number = player_number
  end

  def move(square_number); end
end

class Game
  def initialize(player1, player2)
    @player1 = player1
    @player2 = player2
  end

  def play_turn; end

  def draw_board; end
end

player1 = Player.new(1)
player2 = Player.new(2)
game = Game.new(player1, player2)
