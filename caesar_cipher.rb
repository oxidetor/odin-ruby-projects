# frozen_string_literal: true

def get_shifted_char(char, shift)
  alpha = {
    upchars: %w[A B C D E F G H I J K L M N O P Q R S T U V W X Y Z],
    downchars: %w[a b c d e f g h i j k l m n o p q r s t u v w x y z]
  }
  if alpha[:upchars].include?(char) then charset = :upchars
  elsif alpha[:downchars].include?(char) then charset = :downchars
  else
    return char end

  idx = alpha[charset].index(char)
  idx + shift >= 26 ? alpha[charset][idx + shift - 26] : alpha[charset][idx + shift]
end

def caesar_cipher(str, shift)
  str.each_char.map { |char| get_shifted_char(char, shift) }.join
end

p caesar_cipher('What a string!', 5)
