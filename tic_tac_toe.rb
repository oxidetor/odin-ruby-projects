# frozen_string_literal: true

class Cell
  attr_reader :value, :locked

  def initialize
    @locked = false
    @value = '_'
  end

  def value=(new_value)
    @value = new_value unless @locked
    @locked = true
  end
end

class Player
  attr_accessor :played_cells

  def initialize(player_number)
    @player_number = player_number
    @marker = player_number == 1 ? 'X' : 'O'
    self.played_cells = []
  end
end

class Game
  def initialize(player1, player2)
    @player1 = player1
    @player2 = player2
    @current_player = player1
    @cells = []
    9.times do
      @cells.push(Cell.new)
    end
  end

  def play_game
    loop do
      play_turn
      next unless check_for_winner

      draw_boards
      puts "\e[1;31m#{if @current_player == @player2
                        "Player 1 (X's)"
                      else
                        "Player 2 (O's)"
                      end} WINS!\e[0m Thanks for playing!"
      # puts "\e[1;31m This is red text \e[0m"
      break
    end
  end

  def draw_boards
    draw_board('GAME', @cells.map(&:value))
    draw_board('KEY', (1..9).to_a.map do |num|
                        @cells[num - 1].locked ? '' : num.to_s
                      end)
  end

  def update_cells(selection)
    @cells[selection - 1].value = @current_player == @player1 ? 'X' : 'O'
    @current_player = @current_player == @player1 ? @player2 : @player1
    @current_player.played_cells.push(selection - 1)
  end

  def play_turn
    draw_boards
    selection = nil
    loop do
      selection = player_selection
      if @cells[selection - 1].locked
        puts '--- ! That cell was already played. Pick another one! ---'
        next
      end
      break
    end
    update_cells(selection)

    p @current_player.played_cells
  end

  def check_for_winner
    win_conditions = [
      [0, 1, 2], [3, 4, 5], [6, 7, 8],
      [0, 3, 6], [1, 4, 7], [2, 5, 8],
      [0, 4, 8], [2, 4, 6]
    ]
    win_conditions.each do |win_condition|
      return true if (@current_player.played_cells & win_condition).any? && @current_player.played_cells.size >= 3
    end
    false
  end

  def draw_board(type, values)
    print "\t----------\t#{type}\t----------"
    values.each_with_index do |value, index|
      print "\n\n\n" if (index % 3).zero?
      print "\t#{value}\t"
    end
    print "\n\n\n"
  end

  def player_selection
    puts 'Input a number (1-9) that corresponds to the square you want to play'
    gets.chomp.to_i
  end
end

player1 = Player.new(1)
player2 = Player.new(2)
game = Game.new(player1, player2)
game.play_game
