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
    assert_equal 1, step_to_position(1)
    assert_equal 1, step_to_position(2)
    assert_equal 2, step_to_position(3)
    assert_equal 4, step_to_position(4)
    assert_equal 5, step_to_position(5)
    assert_equal 10, step_to_position(6)
    assert_equal 11, step_to_position(7)
    assert_equal 23, step_to_position(8)
    assert_equal 25, step_to_position(9)
    assert_equal 26, step_to_position(10)
    assert_equal 54, step_to_position(11)
    assert_equal 57, step_to_position(12)
    assert_equal 59, step_to_position(13)
    assert_equal 122, step_to_position(14)
    assert_equal 133, step_to_position(15)
    assert_equal 142, step_to_position(16)
    assert_equal 147, step_to_position(17)
    assert_equal 304, step_to_position(18)
    assert_equal 330, step_to_position(19)
    assert_equal 351, step_to_position(20)
    assert_equal 362, step_to_position(21)
    assert_equal 747, step_to_position(22)
    assert_equal 806, step_to_position(23)
  end

  def test_refactoring
    assert_equal 326, steps_required(361527)
    assert_equal 363010, find_first_value_over_threshold(361527)
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
  attr_reader :coordinates

  def initialize(coordinates: [])
    @coordinates = coordinates
  end

  def value_at(x:, y:)
    coordinate_at(x: x, y: y).value
  end

  def value_of_neighbors(x:, y:)
    NEIGHBORS.reduce(0) { |m, n| m + value_at(x: x + n.x, y: y + n.y) }
  end

  def values
    coordinates.map(&:value)
  end

  def coordinate_at(x:, y:)
    coordinates.find { |c| c.x == x && c.y == y } || Coordinate.new(x: x, y: y, value: 0)
  end

  def next_grid(heading)
    next_x = coordinates.last.x + heading.x
    next_y = coordinates.last.y + heading.y
    next_coordinate = Coordinate.new(
      x: next_x,
      y: next_y,
      value: value_of_neighbors(x: next_x, y: next_y),
    )
    self.class.new(coordinates: coordinates + [next_coordinate])
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
  1.upto(1_000_000) do |i|
    value = step_to_position(i)
    break value if value > threshold
  end
end

def step_to_position(position)
  grid = Grid.new(coordinates: [Coordinate.new(x: 0, y: 0, value: 1)])
  headings = EAST_NORTH_WEST_SOUTH.cycle
  extend_total_paces_on_heading_change = [true, false].cycle

  heading = SOUTH
  total_paces_in_this_heading = 0
  paces_remaining_in_this_heading = 0

  (position - 1).times do
    if paces_remaining_in_this_heading.zero?
      heading = headings.next
      total_paces_in_this_heading = total_paces_in_this_heading.next if extend_total_paces_on_heading_change.next
      paces_remaining_in_this_heading = total_paces_in_this_heading
    end

    paces_remaining_in_this_heading -= 1

    grid = grid.next_grid(heading)
  end

  grid.values.last
end

result_part_1 = steps_required(361527)
result_part_2 = find_first_value_over_threshold(361527)

puts "🎄 " * 40
puts "Steps required for part 1: #{result_part_1}"
puts "First number over threshold for part 2: #{result_part_2}"
puts "🎄 " * 40
