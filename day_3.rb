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

result_part_1 = steps_required(361527)

puts "🎄 " * 40
puts "Steps required for part 1: #{result_part_1}"

class Coordinate

end