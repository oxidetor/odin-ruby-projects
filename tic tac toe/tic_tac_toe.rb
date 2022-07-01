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

class Board
  include TextUtilities

  attr_accessor :cells

  WIN_CONDITIONS = [
    [0, 1, 2], [3, 4, 5], [6, 7, 8],
    [0, 3, 6], [1, 4, 7], [2, 5, 8],
    [0, 4, 8], [2, 4, 6]
  ].freeze

  def initialize(game)
    @game = game
    @cells = []
    9.times do
      @cells.push(Cell.new)
    end
  end

  def all_cells_played?
    @cells.all?(&:locked)
  end

  def cell_already_selected?(board_index)
    cell_addr = board_index_to_cell_index(board_index)
    @cells[cell_addr].locked
  end

  def draw_board
    draw_column_indices
    draw_top_border
    draw_empty_board_lines(2)
    inject_game_data
    draw_bottom_border
  end

  def draw_column_indices
    print "\n#{' ' * 12}A#{' ' * 5}B#{' ' * 5}C\n"
  end

  def draw_top_border
    print "#{' ' * 7}#{'_' * 23}"
  end

  def draw_empty_board_lines(lines)
    print("\n#{' ' * 6}|#{' ' * 23}|" * lines)
  end

  def inject_game_data
    @cells.map(&:value).each_with_index do |value, index|
      draw_row_index(index) if (index % 3).zero?
      draw_cell_value(value, index)
      if (index % 3) == 2
        draw_right_border
        draw_empty_board_lines(index == 8 ? 1 : 2)
      end
    end
  end

  def draw_row_index(index)
    print "\n#{' ' * 3}#{index / 3 + 1}#{' ' * 2}|#{' ' * 1}"
  end

  def draw_right_border
    print "#{' ' * 4}|"
  end

  def draw_cell_value(value, index)
    print "#{' ' * 3}#{if get_winning_combo(@game.current_player.played_cells).include?(index)
                         highlight_cell(@game.current_player)
                       else
                         "#{' ' * 1}#{color_cell(value, @game.current_player, @game.other_player)}#{' ' * 1}"
                       end}"
  end

  def draw_bottom_border
    print "\n#{' ' * 6}|#{'_' * 23}|\n\n\n"
  end

  def color_cell(value, current_player, other_player)
    case value
    when current_player.symbol
      colorize_text(current_player.symbol, current_player.color)
    when other_player.symbol
      colorize_text(other_player.symbol, other_player.color)

    else
      value
    end
  end

  def highlight_cell(current_player)
    highlight_text(" #{bold_text(current_player.symbol)} ", current_player.color)
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
      (board_index[1].to_i - 1) * 3
    when 'B'
      (board_index[1].to_i - 1) * 3 + 1
    when 'C'
      (board_index[1].to_i - 1) * 3 + 2
    end
  end

  def get_winning_combo(played_cells)
    WIN_CONDITIONS.each do |win_condition|
      winning_combo = played_cells & win_condition
      return winning_combo if winning_combo.size >= 3
    end
    []
  end
end

class Game
  include TextUtilities

  attr_reader :current_player, :other_player

  def initialize
    @current_player = Player.new(1, '34', 'X')
    @other_player = Player.new(2, '33', 'O')
    @board = Board.new(self)
  end

  def play_game
    loop do
      play_turn
      break if current_player_won? || @board.all_cells_played?
    end
    display_game_result
  end

  def current_player_won?
    @board.get_winning_combo(@current_player.played_cells).any?
  end

  def play_turn
    @board.draw_board
    print colorize_text("It's your turn, #{@current_player}\n", @current_player.color)
    prompt_player_selection
    switch_current_player unless current_player_won?
  end

  def prompt_player_selection
    selection = nil
    loop do
      print "\nEnter the column and row index for the cell you want to play (e.g., 'A2' / 'c3')\n" \
            ' => '
      selection = gets.chomp.upcase
      break if valid_player_selection?(selection)
    end
    mark_cell_played(@board.board_index_to_cell_index(selection))
  end

  def valid_player_selection?(selection)
    return true unless !@board.valid_board_index?(selection) || @board.cell_already_selected?(selection)

    display_selection_error(selection)
  end

  def display_selection_error(selection)
    if !@board.valid_board_index?(selection)
      puts colorize_text("\nInvalid column and row index. Try again!", '31')
    elsif @board.cell_already_selected?(selection)
      puts colorize_text("\nThat cell was already played. Pick another!", '31')
    else
      puts colorize_text('Error!', '31')
    end
  end

  def mark_cell_played(cell_index)
    @board.cells[cell_index].value = @current_player.symbol
    @current_player.played_cells.push(cell_index)
  end

  def switch_current_player
    @current_player, @other_player = @other_player, @current_player
  end

  def display_game_result
    @board.draw_board
    if current_player_won?
      puts bold_text(colorize_text("#{@current_player} WINS!\n", @current_player.color))
    else
      puts bold_text("It's a DRAW\n")
    end
  end
end

game = Game.new
game.play_game
