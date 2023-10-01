


link = 'https://raw.githubusercontent.com/first20hours/google-10000-english/master/google-10000-english-no-swears.txt'
puts `curl -o  ../words.txt #{link}` unless File.exists? '../words.txt'
