# frozen_string_literal: true

dictionary = %w[below down go going horn how howdy it i low own part partner sit]
words = "Howdy partner, sit down! How's it going?"

def substrings(words, dictionary)
  dictionary.each_with_object(Hash.new(0)) do |dict_word, acc|
    words.split.each do |word|
      acc[dict_word] += 1 if word.downcase.include?(dict_word)
    end
  end
end

p substrings(words, dictionary)
