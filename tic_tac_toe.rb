# frozen_string_literal: true

module Colorize
  def colourize_text(text, color)
    "\u001b[#{color}m#{text}\u001b[0m"
  end

  def highlight_text(text, color)
    "\u001b[#{color.to_i + 10};1m#{text}\u001b[0m"
  end

  def bold_text(text)
    "\u001b[1m#{text}"
  end
end

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
  attr_accessor :played_cells, :colour, :symbol, :number

  def initialize(number, colour, symbol)
    @colour = colour
    @number = number
    @symbol = symbol
    self.played_cells = []
  end

  def to_s
    "Player #{@number} (#{@symbol}'s)"
  end
end

class Game
  include Colorize

  def initialize(player1, player2)
    @current_player = player1
    @other_player = player2
    @cells = []
    9.times do
      @cells.push(Cell.new)
    end
  end

  def play_game
    loop do
      play_turn
      if check_for_winner.any? || check_for_draw
        draw_board
        display_game_result
        break
      end
      switch_current_player
      next
    end
  end

  def check_for_draw
    @cells.all?(&:locked)
  end

  def display_game_result
    if check_for_winner.any?
      puts bold_text(colourize_text("#{@current_player} WINS!\n", @current_player.colour))
    else
      puts bold_text("IT'S A DRAW\n")
    end
  end

  def update_cells(selection)
    @cells[selection - 1].value = @current_player.symbol
    @current_player.played_cells.push(selection - 1)
  end

  def switch_current_player
    @current_player, @other_player = @other_player, @current_player
  end

  def play_turn
    draw_board
    selection = nil
    print colourize_text("It's your turn, #{@current_player}\n", @current_player.colour)
    loop do
      selection = get_player_selection
      next unless valid_player_selection?(selection)

      update_cells(board_index_to_cell(selection))
      break
    end
  end

  def valid_player_selection?(selection)
    unless valid_board_index?(selection)
      display_error('invalid index')
      return false
    end
    cell_addr = board_index_to_cell(selection) - 1
    if @cells[cell_addr].locked
      display_error('cell locked')
      return false
    end
    true
  end

  def display_error(type)
    case type
    when 'invalid index'
      puts colourize_text("\nInvalid column and row index. Try again!", '31')
    when 'cell locked'
      puts colourize_text("\nThat cell was already played. Pick another!", '31')
    else
      puts colourize_text('Error!', '31')
    end
  end

  def check_for_winner
    win_conditions = [
      [0, 1, 2], [3, 4, 5], [6, 7, 8],
      [0, 3, 6], [1, 4, 7], [2, 5, 8],
      [0, 4, 8], [2, 4, 6]
    ]
    win_conditions.each do |win_condition|
      winning_cells = @current_player.played_cells & win_condition
      return winning_cells if winning_cells.size >= 3
    end
    []
  end

  def draw_board
    values = @cells.map(&:value)
    print "\n\n   \t A\t B\t C\t\n    ______________________"
    values.each_with_index do |value, index|
      print "\n   |\n   |\n#{index / 3}  |" if (index % 3).zero?
      if check_for_winner.include?(index)
        print "\t#{highlight_text(' ' + bold_text(@current_player.symbol) +
        ' ', @current_player.colour)} "
      else
        print "\t #{decorate_symbol(value)} "
      end
    end
    print "\n\n\n"
  end

  def decorate_symbol(value)
    case value
    when @current_player.symbol
      colourize_text(@current_player.symbol, @current_player.colour)
    when @other_player.symbol
      colourize_text(@other_player.symbol, @other_player.colour)

    else
      value
    end
  end

  def get_player_selection
    print "\nEnter a column and row index for the cell you want to play" \
          "\n(example: 'A2' or 'c3')\n" \
          "\nYour Selection => "
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
    valid_columns.include?(board_index[0]) &&
      valid_rows.include?(board_index[1]) &&
      board_index.length == 2
  end
end

player1 = Player.new(1, '34', 'X')
player2 = Player.new(2, '33', 'O')
game = Game.new(player1, player2)
game.play_game
