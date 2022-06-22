dictionary = ["below","down","go","going","horn","how","howdy","it","i","low","own","part","partner","sit"]
words = "Howdy partner, sit down! How's it going?"

def substrings(words, dictionary)
    dictionary.reduce(Hash.new(0)) do | acc, dict_word |
        words.split.each {|word| acc[dict_word] += 1 if word.include?(dict_word)}
        acc
    end
end

p substrings(words, dictionary)