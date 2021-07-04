require 'pry'

class Player
  attr_accessor :name

  def initialize(name)
    @name = name
  end
end

class Computer < Player
  PEG_COLORS = { 1 => 'BLACK', 2 => 'WHITE', 3 => 'RED', 4 => 'GREEN', 5 => 'BLUE', 6 => 'YELLOW' }.freeze

  def initialize()
    super('Bob the Code Master')
  end

  def create_code
    peg_arrangement = []
    4.times do
      peg_arrangement.push(PEG_COLORS[Random.rand(1..6)])
    end
    peg_arrangement
  end
end

class Board
  attr_accessor :code, :guess, :possible_codes

  def initialize
    @guess = []
    @code = []
  end

  def finished?(turn)
    if red_pegs == 4
      'WIN'
    elsif turn == 13
      'LOSE'
    else
      'NO'
    end
  end

  def to_s
    "| #{@guess[0]} | #{@guess[1]} | #{@guess[2]} | #{@guess[3]} |\n" \
    "Your answer resulted in #{red_pegs} red peg(s) and #{white_pegs} white peg(s)"
  end

  private

  # Returns the number of pairs which have same location and color
  def red_pegs
    identical_loc_and_color_index.length
  end

  def white_pegs
    code_colors = white_peg_color_spread(@code)
    guess_colors = white_peg_color_spread(@guess)
    white_pegs = 0
    guess_colors.each_key do |peg|
      if code_colors.has_key?(peg)
        # Add the smallest value amongst shared key. This step is repeated for every shared key
        white_pegs += guess_colors[peg] > code_colors[peg] ? code_colors[peg] : guess_colors[peg]
      end
    end
    white_pegs
  end

  # Returns the index of pair(s) of pegs which are the same location and color
  def identical_loc_and_color_index
    matching = []
    @guess.each_with_index do |peg, index|
      matching.push(index) if peg == @code[index]
    end
    matching
  end

  # Return a hash (key: color, value: times encountered)
  # excluding pair of pegs which are the same location and color given array of colors
  def white_peg_color_spread(peg_arrangement)
    index = 0
    peg_arrangement.each_with_object(Hash.new(0)) do |peg, color_spread|
      next if identical_loc_and_color_index.include?(index)

      color_spread[peg] += 1
      index += 1
      color_spread
    end
  end
end

class Game
  attr_reader :turn

  def initialize
    @turn = 1
    @status = 'Ongoing'
  end

  def play_as_guesser(computer)
    board = Board.new
    board.code = computer.create_code
    # Ends at turn 13 as initial turn is 1 and we want to play 12 turns
    until @status == 'Ended'
      puts "\nTurn: #{@turn}\n| [1] | [2] | [3] | [4] |"
      board.guess = player_choice
      @turn += 1
      game_state(board)
    end
    print_peg_sequence(board.code)
  end

  private

  def game_state(board)
    case board.finished?(@turn)
    when 'WIN'
      puts 'Congrats, You have won! The code was:'
      @status = 'Ended'
    when 'LOSE'
      puts 'You have lost! The code was:'
      @status = 'Ended'
    when 'NO'
      puts board
    end
  end

  # Dialogue and functionality to gather player's choices
  def player_choice
    choice = %w[1 2 3 4]
    confirmed = false
    until completed?(choice) && confirmed
      choice_color = player_choose_color
      choice_location = player_choose_location
      choice[choice_location - 1] = choice_color
      print_peg_sequence(choice)
      confirmed = confirmed? if completed?(choice)
    end
    choice
  end

  def print_peg_sequence(sequence)
    puts "\n| #{sequence[0]} | #{sequence[1]} | #{sequence[2]} | #{sequence[3]} |"
    puts "\n"
  end

  def player_choose_color
    puts "Please choose a color\nAvailable colors: Black, White, Red, Blue, Green, Yellow"
    user_color = gets.chomp.upcase
    until %w[BLACK WHITE RED BLUE GREEN YELLOW].include?(user_color)
      puts 'Please choose a valid color'
      user_color = gets.chomp.upcase
    end
    user_color
  end

  def player_choose_location
    puts 'Please choose a position'
    user_location = gets.chomp.to_i
    until (1..4).include?(user_location)
      puts 'Please enter a valid location between 1-4'
      user_location = gets.chomp.to_i
    end
    user_location
  end

  def completed?(peg_sequence)
    complete = true
    peg_sequence.each { |peg| complete = false if (1..4).include?(peg.to_i) }
    complete
  end

  def confirmed?
    puts "Are you sure you want to use this sequence of pegs as a guess?\n[Y/N]"
    user_answer = gets.chomp
    until %w[Y N].include?(user_answer)
      puts 'Please answer Y or N'
      user_answer = gets.chomp
    end
    user_answer == 'Y'
  end
end

class Interface
  attr_reader :game_played

  def initialize
    @games_played = 0
  end

  def start
    puts 'Welcome to Mastermind'
    games_to_play = num_of_games
    computer = Computer.new
    games_to_play.times do
      puts @games_played
      session = Game.new
      session.play_as_guesser(computer)
      @games_played += 1
    end
  end

  private

  def num_of_games
    puts 'Please input how many games you want to play'
    puts 'The value must be between 1-20'
    games = gets.chomp.to_i
    until (1..20).include?(games)
      puts 'Please enter a valid number'
      games = gets.chomp.to_i
    end
    games
  end
end

a = Interface.new
a.start
