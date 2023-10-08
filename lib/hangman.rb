require './get_words'

class Hangman
  attr_reader :tries, :player_name, :word

  def initialize(player_name)
    @player_name = player_name
  end

  def select_word()
    @word = File.open('../words.txt', 'r'){|file| file.readlines.sample.strip}
  end

end


hangman = Hangman.new('samual')
hangman.select_word()
puts hangman.word
