require "minitest"
require "minitest/autorun"
require "pry"
require "awesome_print"

TEST_INPUT = File.read("lib/day_22_test_input.txt")
PUZZLE_INPUT = File.read("lib/day_22_puzzle_input.txt")

class TheTest < Minitest::Test
  def test_part_1
    i = InfiniteGrid.parse(TEST_INPUT)

    7.times { i.next }
    assert_equal 5, i.carrier.infection_count

    63.times { i.next }
    assert_equal 41, i.carrier.infection_count

    9930.times { i.next }
    assert_equal 5587, i.carrier.infection_count
  end

  def test_part_2
  end

  def test_execute_part_1
    i = InfiniteGrid.parse(PUZZLE_INPUT)
    10_000.times { i.next }
    assert_equal 5587, i.carrier.infection_count
  end
end

class InfiniteGrid
  def self.parse(puzzle_input)
    instance = new

    puzzle_input.lines.each_with_index do |row, y|
      row.chomp.chars.each_with_index do |infected_string, x|
        instance.add(x: x, y: -y, infected: infected_string == "#")
      end
    end

    middle = instance.size / 2
    instance.carrier = Carrier.new(x: middle, y: -middle)
    instance
  end

  attr_accessor :nodes, :carrier

  def initialize
    @nodes = Hash.new do |h, k|
      x, y = k.split(",")
      h[k] = Node.new(x: x, y: y)
    end
  end

  def add(x:, y:, infected:)
    key = [x, y].join(",")
    nodes[key] = Node.new(x: x, y: y, infected: infected)
  end

  def get(x:, y:)
    key = [x, y].join(",")
    nodes[key]
  end

  def size
    Math.sqrt(nodes.keys.size).floor
  end

  def next
    carrier.next(self)
    self
  end
end

class Node
  attr_reader :x, :y, :infected

  def initialize(x:, y:, infected: false)
    @x = x
    @y = y
    @infected = infected
  end

  def infected?
    infected
  end

  def toggle
    @infected = !infected
  end
end

class Heading
  attr_reader :x, :y

  def initialize(x:, y:)
    @x = x
    @y = y
  end
end

EAST = Heading.new(x: 1, y: 0)
NORTH = Heading.new(x: 0, y: 1)
WEST = Heading.new(x: -1, y: 0)
SOUTH = Heading.new(x: 0, y: -1)

class Carrier
  attr_reader :x, :y, :heading, :infection_count

  def initialize(x:, y:, heading: NORTH)
    @x = x
    @y = y
    @heading = heading
    @infection_count = 0
  end

  def next(infinite_grid)
    node = infinite_grid.get(x: x, y: y)
    turn(node)
    infect(node)
    move
    self
  end

  private

  def move
    @x = x + heading.x
    @y = y + heading.y
  end

  def turn(node)
    @heading = if node.infected?
                 turn_right
               else
                 turn_left
               end
  end

  def infect(node)
    @infection_count += 1 if node.toggle
  end

  def turn_left
    case heading
    when NORTH
      WEST
    when WEST
      SOUTH
    when SOUTH
      EAST
    when EAST
      NORTH
    end
  end

  def turn_right
    case heading
    when NORTH
      EAST
    when EAST
      SOUTH
    when SOUTH
      WEST
    when WEST
      NORTH
    end
  end
end
