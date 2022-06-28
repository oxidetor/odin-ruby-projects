# frozen_string_literal: true

module TextUtilities
  def colorize_text(text, color)
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
    @value = '-'
  end

  def value=(new_value)
    @value = new_value unless @locked
    @locked = true
  end
end

class Player
  attr_accessor :played_cells
  attr_reader :color, :symbol, :number

  def initialize(number, color, symbol)
    @color = color
    @number = number
    @symbol = symbol
    self.played_cells = []
  end

  def to_s
    "Player #{@number} (#{@symbol}'s)"
  end
end

class Game
  include TextUtilities

  def initialize
    @current_player = Player.new(1, '34', 'X')
    @other_player = Player.new(2, '33', 'O')
    @cells = []
    9.times do
      @cells.push(Cell.new)
    end
  end

  def play_game
    loop do
      play_turn
      break if current_player_won? || all_cells_played?
    end
    display_game_result
  end

  def all_cells_played?
    @cells.all?(&:locked)
  end

  def current_player_won?
    get_winning_combo(@current_player.played_cells).any?
  end

  def get_winning_combo(played_cells)
    win_conditions = [
      [0, 1, 2], [3, 4, 5], [6, 7, 8],
      [0, 3, 6], [1, 4, 7], [2, 5, 8],
      [0, 4, 8], [2, 4, 6]
    ]
    win_conditions.each do |win_condition|
      winning_combo = played_cells & win_condition
      return winning_combo if winning_combo.size >= 3
    end
    []
  end

  def play_turn
    draw_board
    print colorize_text("It's your turn, #{@current_player}\n", @current_player.color)
    get_player_selection
    switch_current_player unless current_player_won?
  end

  def draw_board
    print "\n\n\t#{' ' * 6}A#{' ' * 5}B#{' ' * 5}C\n\t #{'_' * 23}"
    @cells.map(&:value).each_with_index { |value, index| draw_cell(value, index) }
    print "\n\t|#{' ' * 23}|\n\t|#{'_' * 23}|\n\n\n"
  end

  def draw_cell(value, index)
    print "\n\t|#{' ' * 23}|\n\t|#{' ' * 23}|\n    #{index / 3 + 1}\t| " if (index % 3).zero?
    print "   #{if get_winning_combo(@current_player.played_cells).include?(index)
                  highlight_cell
                else
                  " #{color_cell(value)} "
                end}"
    print '    |' if (index % 3) == 2
  end

  def get_player_selection
    selection = nil
    loop do
      print "\nEnter the column and row index for the cell you want to play (e.g., 'A2' / 'c3')\n" \
            ' => '
      selection = gets.chomp.upcase
      break if valid_player_selection?(selection)
    end
    mark_cell_played(board_index_to_cell_index(selection))
  end

  def valid_player_selection?(selection)
    return true unless !valid_board_index?(selection) || cell_already_selected?(selection)

    display_selection_error(selection)
  end

  def valid_board_index?(board_index)
    valid_rows = %w[1 2 3]
    valid_columns = %w[A B C]
    valid_columns.include?(board_index[0]) &&
      valid_rows.include?(board_index[1]) &&
      board_index.length == 2
  end

  def board_index_to_cell_index(board_index)
    case board_index[0]
    when 'A'
      (board_index[1].to_i - 1) * 3 + 1
    when 'B'
      (board_index[1].to_i - 1) * 3 + 2
    when 'C'
      (board_index[1].to_i - 1) * 3 + 3
    end
  end

  def cell_already_selected?(board_index)
    cell_addr = board_index_to_cell_index(board_index) - 1
    @cells[cell_addr].locked
  end

  def display_selection_error(selection)
    if !valid_board_index?(selection)
      puts colorize_text("\nInvalid column and row index. Try again!", '31')
    elsif cell_already_selected?(selection)
      puts colorize_text("\nThat cell was already played. Pick another!", '31')
    else
      puts colorize_text('Error!', '31')
    end
  end

  def mark_cell_played(selection)
    @cells[selection - 1].value = @current_player.symbol
    @current_player.played_cells.push(selection - 1)
  end

  def switch_current_player
    @current_player, @other_player = @other_player, @current_player
  end

  def display_game_result
    draw_board
    if current_player_won?
      puts bold_text(colorize_text("#{@current_player} WINS!\n", @current_player.color))
    else
      puts bold_text("It's a DRAW\n")
    end
  end

  def color_cell(value)
    case value
    when @current_player.symbol
      colorize_text(@current_player.symbol, @current_player.color)
    when @other_player.symbol
      colorize_text(@other_player.symbol, @other_player.color)

    else
      value
    end
  end

  def highlight_cell
    highlight_text(" #{bold_text(@current_player.symbol)} ", @current_player.color)
  end
end

game = Game.new
game.play_game
