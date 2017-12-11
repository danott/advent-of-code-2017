require "minitest"
require "minitest/autorun"
require "pry"
require "awesome_print"

PUZZLE_INPUT = File.read("lib/day_11_input.txt")

class TheTest < Minitest::Test
  def test_part_1
    assert_equal %w(ne ne ne).size, minimal_directions("ne,ne,ne")
    assert_equal [].size, minimal_directions("ne,ne,sw,sw")
    assert_equal %w(se se).size, minimal_directions("ne,ne,s,s")
    assert_equal %w(s s sw).size, minimal_directions("se,sw,se,sw,sw")
    assert_equal 643, minimal_directions(PUZZLE_INPUT)
  end

  def test_part_2
    assert_equal 1471, longest_distance(PUZZLE_INPUT)
  end
end

def minimal_directions(string)
  steps = string.split(",")
  HexDirection.new(steps: steps).call.steps.size
end

def longest_distance(string)
  steps = string.split(",")
  hex = HexDirection.new(steps: [steps.shift])

  steps.reduce(0) do |a, e|
    hex.steps << e
    hex.call
    [a, hex.steps.size].max
  end
end


class HexDirection
  NORTH_WEST = "nw".freeze
  NORTH = "n".freeze
  NORTH_EAST = "ne".freeze
  SOUTH_WEST = "sw".freeze
  SOUTH = "s".freeze
  SOUTH_EAST = "se".freeze

  attr_accessor :steps

  def initialize(steps: [])
    @steps = steps
  end

  def next
    if steps.include?(NORTH) && steps.include?(SOUTH)
      steps.delete_at(steps.index(NORTH))
      steps.delete_at(steps.index(SOUTH))
    elsif steps.include?(NORTH_EAST) && steps.include?(SOUTH_WEST)
      steps.delete_at(steps.index(NORTH_EAST))
      steps.delete_at(steps.index(SOUTH_WEST))
    elsif steps.include?(NORTH_WEST) && steps.include?(SOUTH_EAST)
      steps.delete_at(steps.index(NORTH_WEST))
      steps.delete_at(steps.index(SOUTH_EAST))
    elsif steps.include?(NORTH) && steps.include?(SOUTH_WEST)
      steps[steps.index(NORTH)] = NORTH_WEST
      steps.delete_at(steps.index(SOUTH_WEST))
    elsif steps.include?(NORTH) && steps.include?(SOUTH_EAST)
      steps[steps.index(NORTH)] = NORTH_EAST
      steps.delete_at(steps.index(SOUTH_EAST))
    elsif steps.include?(SOUTH) && steps.include?(NORTH_EAST)
      steps[steps.index(SOUTH)] = SOUTH_EAST
      steps.delete_at(steps.index(NORTH_EAST))
    elsif steps.include?(SOUTH) && steps.include?(NORTH_WEST)
      steps[steps.index(SOUTH)] = SOUTH_WEST
      steps.delete_at(steps.index(NORTH_WEST))
    elsif steps.include?(SOUTH_EAST) && steps.include?(SOUTH_WEST)
      steps[steps.index(SOUTH_EAST)] = SOUTH
      steps.delete_at(steps.index(SOUTH_WEST))
    elsif steps.include?(NORTH_EAST) && steps.include?(NORTH_WEST)
      steps[steps.index(NORTH_EAST)] = NORTH
      steps.delete_at(steps.index(NORTH_WEST))
    end
    self
  end

  def call
    self.next until done?
    self
  end

  def done?
    steps.size == self.next.steps.size
  end
end
