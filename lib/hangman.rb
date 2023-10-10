require './get_words'
require 'yaml'

class Hangman
  attr_reader :tries, :player_name, :word, :game_ended

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
      @guess = kwargs[:guess]
    else
      @word = ''
      @tries = 10
      @guess = ''
    end
  end

  def select_word()
    get_words
    while @word.length < 5 || @word.length > 12
      @word = File.open('../words.txt', 'r'){|file| file.readlines.sample.strip}
    end
    @guess = '_' * @word.length
  end

  def player_guess(guess)
    if @word.include?(guess)
      puts 'u guessed right'
      @game_ended = true
    else
      @tries = @tries - 1
      puts "you gussed wrong #{@tries} left"
    end
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
