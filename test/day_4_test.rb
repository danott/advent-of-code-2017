# http://adventofcode.com/2017/day/4
#
# --- Day 4: High-Entropy Passphrases ---
#
# A new system policy has been put in place that requires all accounts to use a passphrase instead
# of simply a password. A passphrase consists of a series of words (lowercase letters) separated by
# spaces.
#
# To ensure security, a valid passphrase must contain no duplicate words.
#
# For example:
#
# aa bb cc dd ee is valid.
# aa bb cc dd aa is not valid - the word aa appears more than once.
# aa bb cc dd aaa is valid - aa and aaa count as different words.
#
# The system's full passphrase list is available as your puzzle input. How many passphrases are
# valid?
#
# --- Part Two ---
#
# For added security, yet another system policy has been put in place. Now, a valid passphrase must
# contain no two words that are anagrams of each other - that is, a passphrase is invalid if any
# word's letters can be rearranged to form any other word in the passphrase.
#
# For example:
#
# abcde fghij is a valid passphrase.
# abcde xyz ecdab is not valid - the letters from the third word can be rearranged to form the first word.
# a ab abc abd abf abj is a valid passphrase, because all letters need to be used when forming another word.
# iiii oiii ooii oooi oooo is valid.
# oiii ioii iioi iiio is not valid - any of these words can be rearranged to form any other word.
# Under this new system policy, how many passphrases are valid?

require "minitest"
require "minitest/autorun"

class TheTest < Minitest::Test
  def test_part_1
    fixture = <<~END
      aa bb cc dd ee
      aa bb cc dd aa
      aa bb cc dd aaa
    END

    assert all_words_uniq?(fixture.lines[0])
    refute all_words_uniq?(fixture.lines[1])
    assert all_words_uniq?(fixture.lines[2])

    assert_equal 2, count_valid_uniq_words_passphrases(fixture)
  end

  def test_part_2
    fixture = <<~END
      abcde fghij
      abcde xyz ecdab
      a ab abc abd abf abj
      iiii oiii ooii oooi oooo
      oiii ioii iioi iiio
    END

    assert all_anagrams_uniq?(fixture.lines[0])
    refute all_anagrams_uniq?(fixture.lines[1])
    assert all_anagrams_uniq?(fixture.lines[2])
    assert all_anagrams_uniq?(fixture.lines[3])
    refute all_anagrams_uniq?(fixture.lines[4])

    assert_equal 3, count_valid_uniq_anagrams_passphrases(fixture)
  end

  def test_refactoring
    fixture = File.read("./day_4_input.txt")

    assert_equal 386, count_valid_uniq_words_passphrases(fixture)
    assert_equal 208, count_valid_uniq_anagrams_passphrases(fixture)
  end
end

def all_anagrams_uniq?(string)
  words = string.split
  words = words.map { |w| w.chars.sort.join }
  words == words.uniq
end

def all_words_uniq?(string)
  words = string.split
  words == words.uniq
end

def count_valid_passphrases(string)
  string.lines.select { |line| yield line }.count
end

def count_valid_uniq_words_passphrases(string)
  count_valid_passphrases(string) { |l| all_words_uniq?(l) }
end

def count_valid_uniq_anagrams_passphrases(string)
  count_valid_passphrases(string) { |l| all_anagrams_uniq?(l) }
end

fixture = File.read("./day_4_input.txt")
result_part_1 = count_valid_uniq_words_passphrases(fixture)
result_part_2 = count_valid_uniq_anagrams_passphrases(fixture)

puts "🎄 " * 40
puts "Valid passphrases part 1: #{result_part_1}"
puts "Valid passphrases part 2: #{result_part_2}"
puts "🎄 " * 40
