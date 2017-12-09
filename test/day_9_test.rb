require "minitest"
require "minitest/autorun"
require "pry"
require "awesome_print"

class TheTest < Minitest::Test
  def test_part_1
    assert_equal 1, number_of_groups("{}")
    assert_equal 3, number_of_groups("{{{}}}")
    assert_equal 3, number_of_groups("{{},{}}")
    assert_equal 6, number_of_groups("{{{},{},{{}}}}")
    assert_equal 1, number_of_groups("{<{},{},{{}}>}")
    assert_equal 1, number_of_groups("{<a>,<a>,<a>,<a>}")
    assert_equal 5, number_of_groups("{{<a>},{<a>},{<a>},{<a>}}")
    assert_equal 2, number_of_groups("{{<!>},{<!>},{<!>},{<a>}}")

    assert_equal 1, score_of_groups("{}")
    assert_equal 6, score_of_groups("{{{}}}")
    assert_equal 5, score_of_groups("{{},{}}")
    assert_equal 16, score_of_groups("{{{},{},{{}}}}")
    assert_equal 1, score_of_groups("{<a>,<a>,<a>,<a>}")
    assert_equal 9, score_of_groups("{{<ab>},{<ab>},{<ab>},{<ab>}}")
    assert_equal 9, score_of_groups("{{<!!>},{<!!>},{<!!>},{<!!>}}")
    assert_equal 3, score_of_groups("{{<a!>},{<a!>},{<a!>},{<ab>}}")
  end

  def test_part_2
    assert_equal 0, amount_of_garbage_removed("{<>}")
    assert_equal 17, amount_of_garbage_removed("{<random characters>}")
    assert_equal 3, amount_of_garbage_removed("{<<<<>}")
    assert_equal 2, amount_of_garbage_removed("{<{!>}>}")
    assert_equal 0, amount_of_garbage_removed("{<!!>}")
    assert_equal 0, amount_of_garbage_removed("{<!!!>>}")
    assert_equal 10, amount_of_garbage_removed("{<{o\"i!a,<{i<a>}")
  end

  def test_refactoring
    assert_equal 11846, score_of_groups(PUZZLE_INPUT)
    assert_equal 6285, amount_of_garbage_removed(PUZZLE_INPUT)
  end
end

def number_of_groups(stream)
  Group.parse(stream).flatten.count
end

def score_of_groups(stream)
  Group.parse(stream).score
end

def amount_of_garbage_removed(stream)
  Group.parse(stream).all_the_garbage.count
end

class Group
  attr_accessor :parent, :children, :garbage

  def self.parse(stream)
    garbage = false
    chars = stream.chars
    group = nil

    until chars.none?
      char = chars.shift

      if garbage
        case char
        when "!"
          chars.shift
        when ">"
          garbage = false
        else
          group.garbage << char
        end
      else
        case char
        when "{"
          next_group = new(parent: group)
          group.children << next_group if group
          group = next_group
        when "}"
          group = group.parent unless group.parent.nil?
        when "<"
          garbage = true
        end
      end
    end

    group
  end

  def flatten
    [self] + children.map(&:flatten).flatten
  end

  def score
    fail unless parent.nil?
    flatten.map(&:individual_score).reduce(&:+)
  end

  def individual_score
    return 1 if parent.nil?
    parent.individual_score + 1
  end

  def all_the_garbage
    garbage + children.map(&:all_the_garbage).flatten
  end

  def initialize(parent: nil, children: [], garbage: [])
    @parent = parent
    @children = children
    @garbage = garbage
  end
end

PUZZLE_INPUT = File.read("./day_9_input.txt")
puts "🎄 " * 40
puts "Total score is #{Group.parse(PUZZLE_INPUT).score}"
puts "Total garbage removed is #{Group.parse(PUZZLE_INPUT).all_the_garbage.count}"
puts "🎄 " * 40
