require './hangman.rb'

def show_saved_games()
  puts `clear`
  puts 'Here is a list of saved games:'
  file_number = 0
  file_names = Dir.entries("../saved games/")
  file_names.select! { |filename| filename.length > 3 }
  return file_names[0] unless file_names.length > 1
  file_names.each_with_index do |filename, index|
    puts "#{index + 1} - #{filename}"
  end
  print 'Please Enter the number of the file you want to load: '
  file_number = gets.chomp until (file_number.to_i > 0 and file_number.to_i <= file_names.length)
  return file_names[file_number.to_i - 1]
end

def make_game_instance(instance_type)
  hangman_game = nil
  case instance_type
  when '1'
    puts "Please enter your name[This name will be used to save your game]:"
    player_name = gets.chomp
    hangman_game = Hangman.new(player_name: player_name)
    hangman_game.select_word
  when '2'
    name = show_saved_games()
    if File.exists?("../saved games/#{name}")
      hangman_game = Hangman.load_game(name)
    end
  end
  return hangman_game
end

def enter_continue()
  print "Press Enter to continue"
  gets
end

while true


  load_save = Hangman.start_message()
  hangman_game = nil
  if '12'.include?(load_save)
    hangman_game = make_game_instance(load_save)
    next if hangman_game == nil
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
      puts 'save game?[y/n]'
      save_game = gets.chomp
      if save_game.downcase == 'y'
        print "Enter save file name: "
        file_name = gets.chomp
        hangman_game.save_game(file_name)
        enter_continue()
      end
      break
    end
    hangman_game.player_guess(guess)
    break if hangman_game.game_ended
  end
  hangman_game.display_state
  enter_continue()
end
