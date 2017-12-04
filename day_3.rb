require "minitest"
require "minitest/autorun"

class TheTest < Minitest::Test
  def test_part_1
    assert_equal 0, steps_required(1)

    assert_equal 1, steps_required(2)
    assert_equal 2, steps_required(3)
    assert_equal 1, steps_required(4)

    assert_equal 2, steps_required(5)
    assert_equal 1, steps_required(6)
    assert_equal 2, steps_required(7)
    assert_equal 1, steps_required(8)
    assert_equal 2, steps_required(9)

    assert_equal 3, steps_required(10)
    assert_equal 2, steps_required(11)
    assert_equal 3, steps_required(12)
    assert_equal 4, steps_required(13)
    assert_equal 3, steps_required(14)
    assert_equal 2, steps_required(15)
    assert_equal 3, steps_required(16)

    assert_equal 4, steps_required(17)
    assert_equal 3, steps_required(18)
    assert_equal 2, steps_required(19)
    assert_equal 3, steps_required(20)
    assert_equal 4, steps_required(21)
    assert_equal 3, steps_required(22)
    assert_equal 2, steps_required(23)
    assert_equal 3, steps_required(24)
    assert_equal 4, steps_required(25)

    assert_equal 5, steps_required(26)
    assert_equal 4, steps_required(27)
    assert_equal 3, steps_required(28)
    assert_equal 4, steps_required(29)
    assert_equal 5, steps_required(30)
    assert_equal 6, steps_required(31)
    assert_equal 5, steps_required(32)
    assert_equal 4, steps_required(33)
    assert_equal 3, steps_required(34)
    assert_equal 4, steps_required(35)
    assert_equal 5, steps_required(36)

    assert_equal 31, steps_required(1024)
  end

  def test_part_2
    skip
    assert_equal
  end

  def test_refactoring
    assert_equal 326, steps_required(361527)
  end
end

def steps_required(starting_position)
  next_square_root = Math.sqrt(starting_position).ceil
  next_square_root += 1 if next_square_root.even?

  maximum_distance = next_square_root - 1
  minimum_distance = maximum_distance / 2

  direction = -1
  distance = maximum_distance
  current_position = next_square_root ** 2

  while current_position != starting_position
    distance += direction
    direction *= -1 if [minimum_distance, maximum_distance].include?(distance)
    current_position -= 1
  end

  distance
end

class Grid
  attr_accessor :coordinates

  def initialize(coordinates: [])
    @coordinates = coordinates
  end

  def value_at(x:, y:)
    coordinate_at(x: x, y: y).value
  end

  def coordinate_at(x:, y:)
    coordinates.find { |c| c.x == x && c.y == y } || Coordinate.new(x: x, y: y, value: 0)
  end
end

class Coordinate
  attr_reader :x, :y, :value

  def initialize(x:, y:, value: 0)
    @x = x
    @y = y
    @value = value
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
NORTH_EAST = Heading.new(x: 1, y: 1)
NORTH = Heading.new(x: 0, y: 1)
NORTH_WEST = Heading.new(x: -1, y: 1)
WEST = Heading.new(x: -1, y: 0)
SOUTH_WEST = Heading.new(x: -1, y: -1)
SOUTH = Heading.new(x: 0, y: -1)
SOUTH_EAST = Heading.new(x: 1, y: -1)

NEIGHBORS = [EAST, NORTH_EAST, NORTH, NORTH_WEST, WEST, SOUTH_WEST, SOUTH, SOUTH_EAST]
EAST_NORTH_WEST_SOUTH = [EAST, NORTH, WEST, SOUTH]

def find_first_value_over_threshold(threshold)
  directions = Enumerator.new do |yielder|
    dir = EAST
    loop do
      yielder << dir
      dir = case dir
            when EAST
              NORTH
            when NORTH
              WEST
            when WEST
              SOUTH
            when SOUTH
              EAST
            end
    end
  end

  grid = Grid.new(coordinates: [Coordinate.new(x: 0, y: 0, value: 1)])
  paces = 0

  while grid.coordinates.last.value < threshold
    paces = paces.next
    2.times do
      direction = directions.next
      paces.times do
        next_position = Heading.new(
          x: grid.coordinates.last.x + direction.x,
          y: grid.coordinates.last.y + direction.y,
        )
        next_value = NEIGHBORS.reduce(0) do |memo, h|
          memo + grid.value_at(
            x: next_position.x + h.x,
            y: next_position.y + h.y,
           )
        end
        next_coordinate = Coordinate.new(
          x: next_position.x,
          y: next_position.y,
          value: next_value,
        )
        grid = Grid.new(coordinates: grid.coordinates + [next_coordinate])
        return grid.coordinates.last.value if grid.coordinates.last.value > threshold
      end
    end
  end
end

result_part_1 = steps_required(361527)
result_part_2 = find_first_value_over_threshold(361527)

puts "🎄 " * 40
puts "Steps required for part 1: #{result_part_1}"
puts "First number over threshold for part 2: #{result_part_2}"
puts "🎄 " * 40
