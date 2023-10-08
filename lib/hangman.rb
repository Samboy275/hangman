require './get_words'
require 'yaml'

class Hangman
  attr_reader :tries, :player_name, :word

  def initialize(player_name = '', tries = 10, word = '')
    @player_name = player_name
    @word = word
    @tries = tries
  end

  def self. initialize_from_load(ser_obj)
    @word = ser_obj[:word]
    @tries = ser_obj[:tries]
    @player_name = ser_obj[:player_name]
  end

  def select_word()
    get_words
    while @word.length < 5 || @word.length > 12
      @word = File.open('../words.txt', 'r'){|file| file.readlines.sample.strip}
    end

  end

  def to_s()
    "#{@player_name} #{@tries} #{@word}"
  end

  def to_yaml
    serilized_object = YAML.dump({
      :player_name => @player_name,
      :word => @word,
      :tries => @tries,
    })
    serilized_object
  end

  def self.from_ymal(serilized_object)
    hangman = Hangman.new(player_name=serilized_object[:player_name],
                          tries=serilized_object[:tries],
                          word=serilized_object[:word])
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
    return self.from_ymal(ser_obj)
  end

end


hangman = Hangman.new('samual')
hangman.select_word
puts hangman

hangman.save_game()

puts Hangman.load_game('samual')
