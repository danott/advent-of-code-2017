require "minitest"
require "minitest/autorun"
require "pry"
require "awesome_print"

PUZZLE_INPUT = File.read("lib/day_16_input.txt")

class TheTest < Minitest::Test
  def test_part_1
    dance = Dance.from_string("abcde")

    assert_equal "eabcd", dance.execute("s1").to_s
    assert_equal "eabdc", dance.execute("x3/4").to_s
    assert_equal "baedc", dance.execute("pe/b").to_s

    dance = Dance.from_string("abcdefghijklmnop")
    PUZZLE_INPUT.split(",").each do |dance_move_string|
      dance.execute(dance_move_string)
    end
    assert_equal "fnloekigdmpajchb", dance.to_s
  end

  def test_part_2
    dance = Dance.from_string("abcdefghijklmnop")
    dance_moves = PUZZLE_INPUT.split(",").map { |string| decode(string) }
    dance_history = [dance.to_s]

    iterations_to_loop = 1_000_000_000.times do |i|
      dance_moves.each { |dance_move_args| dance.public_send(*dance_move_args) }
      break dance_history.size if dance_history.include? dance.to_s
      dance_history << dance.to_s
    end

    to_s = dance_history[(1_000_000_000 % iterations_to_loop)]

    assert_equal "amkjepdhifolgncb", to_s
  end
end


class Dance
  attr_reader :line

  def self.from_string(string)
    new(line: string.chars)
  end

  def initialize(line: [])
    @line = line
  end

  def to_s
    line.join
  end

  def spin(spaces)
    line.unshift(*line.pop(spaces))
    self
  end

  def exchange(left_index, right_index)
    swap = line[left_index]
    line[left_index] = line[right_index]
    line[right_index] = swap
    self
  end

  def partner(left_entity, right_entity)
    exchange(line.index(left_entity), line.index(right_entity))
  end

  def execute(dance_move_string)
    case dance_move_string[0]
    when "s"
      amount = dance_move_string[1, dance_move_string.length].to_i
      spin(amount)
    when "x"
      indexes = dance_move_string[1, dance_move_string.length].split("/").map(&:to_i)
      exchange(*indexes)
    when "p"
      indexes = dance_move_string[1, dance_move_string.length].split("/")
      partner(*indexes)
    end
  end
end

def decode(dance_move_string)
  case dance_move_string[0]
  when "s"
    amount = dance_move_string[1, dance_move_string.length].to_i
    [:spin, amount]
  when "x"
    indexes = dance_move_string[1, dance_move_string.length].split("/").map(&:to_i)
    [:exchange] + indexes
  when "p"
    entities = dance_move_string[1, dance_move_string.length].split("/")
    [:partner] + entities
  end
end