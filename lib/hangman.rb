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
      @player_word = kwargs[:player_word]
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
      puts "Game Over! better luck next time the correct word was #{@word}"
    else
      puts `clear`
      puts "You have #{@tries} left"
      puts "Your guess so far:\n #{@player_word}"
    end
  end
  def make_guess_cover()
    guess_cover = @word.dup
    @player_word.split('').each_with_index do |letter, index|
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
      :player_word => @player_word,
      :saved_load => true
    })
    serilized_object
  end

  def self.from_yaml(serilized_object)
    hangman = Hangman.new(serilized_object)
    return hangman
  end

  def save_game(filename)
    dubplicates = Dir.entries('../saved games/').select {|fname| fname.include?(filename)}
    filename = filename + '_' + (dubplicates.length + 1).to_s
    File.open("../saved\ games/#{filename}.yml", 'w') do |file|
      hangman_ser = self.to_yaml()
      file.write hangman_ser
      puts "game saved as #{filename}"
    end
  end

  def self.load_game(filename)
    ser_obj = YAML.load(File.read("../saved\ games/#{filename}"))
    return self.from_yaml(ser_obj)
  end

end
