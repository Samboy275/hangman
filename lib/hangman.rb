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

  def select_word()
    get_words
    while @word.length < 5 || @word.length > 12
      @word = File.open('../words.txt', 'r'){|file| file.readlines.sample.strip}
    end
    @player_word = '_' * @word.length
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
      if @word.include?(guess)
        @player_word[@word.index(guess)] = guess
        puts player_word
      else
        @tries = @tries - 1
        puts "you gussed wrong #{@tries} left"
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


hangman = Hangman.new(player_name:'samual')
hangman.select_word
puts hangman

while hangman.tries > 0
  guess = gets.chomp
  hangman.player_guess(guess)
  break if hangman.game_ended
end
