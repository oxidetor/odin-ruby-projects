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
      break
    end
  end

  def update_cells(selection)
    @cells[selection - 1].value = @current_player == @player1 ? 'X' : 'O'
    @current_player = @current_player == @player1 ? @player2 : @player1
    @current_player.played_cells.push(selection - 1)
  end

  def play_turn
    draw_board
    selection = nil
    loop do
      board_index = player_selection
      unless valid_board_index?(board_index)
        puts '--- Please enter a valid column and row index (e.g; "A2" or "b3")'
        next
      end
      selection = board_index_to_cell(board_index)
      if @cells[selection - 1].locked
        puts '--- ! That cell was already played. Pick another one! ---'
        next
      end
      break
    end
    update_cells(selection)
  end

  def check_for_winner
    win_conditions = [
      [0, 1, 2], [3, 4, 5], [6, 7, 8],
      [0, 3, 6], [1, 4, 7], [2, 5, 8],
      [0, 4, 8], [2, 4, 6]
    ]
    win_conditions.each do |win_condition|
      return true if (@current_player.played_cells & win_condition).size >= 3
    end
    false
  end

  def draw_board
    values = @cells.map(&:value)
    print "\n   \tA\tB\tC\t\n"
    print '    ______________________'
    row = 1
    values.each_with_index do |value, index|
      if (index % 3).zero?
        print "\n   |\n   |\n#{row}  |"
        row += 1
      end
      print "\t#{value}"
    end
    print "\n\n\n"
  end

  def player_selection
    puts 'Input a column+row index for the square you want to play (example: "A2" or "a2")'
    gets.chomp.upcase
  end

  def board_index_to_cell(board_index)
    case board_index[0]
    when 'A'
      (board_index[1].to_i - 1) * 3 + 1
    when 'B'
      (board_index[1].to_i - 1) * 3 + 2
    when 'C'
      (board_index[1].to_i - 1) * 3 + 3
    end
  end

  def valid_board_index?(board_index)
    valid_rows = %w[1 2 3]
    valid_columns = %w[A B C]
    valid_columns.include?(board_index[0]) && valid_rows.include?(board_index[1]) && board_index.length == 2
  end
end

player1 = Player.new(1)
player2 = Player.new(2)
game = Game.new(player1, player2)
game.play_game
