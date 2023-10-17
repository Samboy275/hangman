require './get_words'
require 'yaml'

class Hangman
  attr_reader :tries, :player_name, :word, :game_ended, :player_word

  def initialize(kwargs)
    if kwargs[:player_name].strip == ''
      puts 'Please enter a valid name'
      return
    end
    @player_name = kwargs[:player_name]
    @game_ended = false
    if kwargs[:saved_load] == true
      @word = kwargs[:word]
      @tries = kwargs[:tries]
      @player_word = kwargs[:guess]
    else
      @word = ''
      @tries = 10
      @player_word = ''
    end
  end
  def self.start_message
    puts `clear`
    player_selection = '6'
    puts "Welcome to hangman the terminal version"
    puts "Game Rules:\n1- You will try to guess a word\n
          2- You can try guessing one letter at a time or guess the whole word\n
          3- Guessing the whole world is risk it all if you guess wrong it is game over\n
          4- you have 10 tries guessing letters\n
          5- Have fun :D."
    puts "1- New Game\n2- Load Game\n3- Exit"
    player_selection = gets.chomp until '123'.include?(player_selection)
    player_selection
  end

  def select_word()
    puts 'Selecting a random word....'
    self.get_words
    while @word.length < 5 || @word.length > 12
      @word = File.open('../words.txt', 'r'){|file| file.readlines.sample.strip}
    end
    @player_word = '_' * @word.length
    puts 'Word selected.....'
  end

  def display_state()
    if @game_ended
      puts "Congrats you won by guessing the word it was #{@word}!!"
    elsif @tries == 0
      puts 'Game Over! better luck next time'
    else
      puts `clear`
      puts "You have #{@tries} left"
      puts "Your guess so far:\n #{@player_word}"
    end
  end
  def make_guess_cover()
    guess_cover = @word.dup
    @player_word.split('').each_with_index do |letter, index|
      puts letter
      guess_cover[index] = '_' unless letter != @word[index]
    end
    guess_cover
  end

  def player_guess(guess)
    if guess.length > 1
      puts 'You sure you want to guess the whole word and risk game over?[y/n]'
      confirmation = gets.chomp().downcase
      if confirmation == 'y'
        if guess != word
          puts "you lost the correct word is #{@word}"
          @tries = 0
          return
        end
        @player_word = guess
      end
    else
      # this variable holds the remaining letters in the word
      guess_cover = self.make_guess_cover()
      if @word.include?(guess) and @player_word.count(guess) < @word.count(guess)
        @player_word[guess_cover.index(guess)] = guess
      else
        @tries = @tries - 1
      end
    end
    @game_ended = true unless @word != @player_word
  end

  def to_s()
    "#{@player_name} #{@tries} #{@word}"
  end

  # serializtion methods for saving and loading
  def to_yaml
    serilized_object = YAML.dump({
      :player_name => @player_name,
      :word => @word,
      :tries => @tries,
      :saved_load => true
    })
    serilized_object
  end

  def self.from_yaml(serilized_object)
    hangman = Hangman.new(serilized_object)
    return hangman
  end

  def save_game()
    File.open("../saved\ games/#{@player_name}.yml", 'w') do |file|
      hangman_ser = self.to_yaml()
      file.write hangman_ser
      puts "game saved as #{@player_name}"
    end
  end

  def self.load_game(player_name)
    ser_obj = YAML.load(File.read("../saved\ games/#{player_name}.yml"))
    return self.from_yaml(ser_obj)
  end

end

while true


  load_save = Hangman.start_message()
  hangman_game = nil
  if load_save == '1'
    puts "Please enter your name[This name will be used to save your game]:"
    player_name = gets.chomp
    hangman_game = Hangman.new(player_name: player_name)
    hangman_game.select_word
  elsif load_save == '2'
    puts "please enter player name to load the game"
    name = gets.chomp
    if File.exists?("../saved games/#{name}.yml")
      hangman_game = Hangman.load_game(name)
    else
      puts 'No saved games found proceeding for a new game'
      next
    end
  else
    break
  end
  response = ''
  puts "ready?[y,n]"
  response = gets.chomp until 'yYnN'.include?(response)
  next if response.downcase == 'n'
  while hangman_game.tries > 0
    hangman_game.display_state
    puts "To exit to main menu please type EXIT in caps instead of typing a guess"
    puts 'Type your guess'
    guess = gets.chomp
    if guess == "EXIT"
      save_game = 'n'
      puts 'return to main menu?[y/n]'
      save_game = gets.chomp
      if save_game.downcase == 'y'
        hangman_game.save_game()
      end
      break
    end
    hangman_game.player_guess(guess)
    break if hangman_game.game_ended
  end
  hangman_game.display_state
  puts "Press Enter to continue"
  gets
end
