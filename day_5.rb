require "minitest"
require "minitest/autorun"
require "pry"

class TheTest < Minitest::Test
  def test_part_1
    fixture = "0 3 0 1 -3"
    expected = JumpInstructionMaze.parse(fixture, incrementor: INCREMENTOR_PART_1)
    assert_equal [(0), 3, 0, 1, -3], expected.to_a
    refute expected.escaped?

    expected = expected.next
    assert_equal [(1), 3, 0, 1, -3], expected.to_a
    refute expected.escaped?

    expected = expected.next
    assert_equal [2, (3), 0, 1, -3], expected.to_a
    refute expected.escaped?

    expected = expected.next
    assert_equal [2, 4, 0, 1, (-3)], expected.to_a
    refute expected.escaped?

    expected = expected.next
    assert_equal [2, (4), 0, 1, -2], expected.to_a
    refute expected.escaped?

    expected = expected.next
    assert_equal [2, 5, 0, 1, -2], expected.to_a
    assert expected.escaped?

    assert_equal 5, JumpInstructionMaze.steps_required(fixture, incrementor: INCREMENTOR_PART_1)
  end

  def test_part_2
    fixture = "0 3 0 1 -3"
    expected = JumpInstructionMaze.parse(fixture, incrementor: INCREMENTOR_PART_2)

    10.times { expected = expected.next }
    assert_equal [2, 3, 2, 3, -1], expected.to_a
    assert expected.escaped?

    assert_equal 10, JumpInstructionMaze.steps_required(fixture, incrementor: INCREMENTOR_PART_2)
  end
end

class JumpInstructionMaze
  def self.steps_required(string, incrementor:)
    maze = parse(string, incrementor: incrementor)
    iterations = 0

    until maze.escaped?
      maze = maze.next
      iterations += 1
    end

    iterations
  end

  def self.parse(string, incrementor:)
    instructions = string.split.map(&:to_i)
    self.new(instructions: instructions, cursor: 0, incrementor: incrementor)
  end

  attr_reader :instructions, :cursor, :incrementor

  def initialize(instructions:, cursor:, incrementor:)
    @instructions = instructions
    @cursor = cursor
    @incrementor = incrementor
  end

  def next
    return self if escaped?
    next_instructions = instructions.each_with_index.map do |instruction, index|
      cursor == index ? incrementor.call(instruction) : instruction
    end
    next_cursor = cursor + instructions[cursor]
    self.class.new(instructions: next_instructions, cursor: next_cursor, incrementor: incrementor)
  end

  def to_a
    instructions
  end

  def escaped?
    cursor >= instructions.length
  end
end

INPUT = File.read("./day_5_input.txt")
INCREMENTOR_PART_1 = proc { |instruction| instruction + 1 }
INCREMENTOR_PART_2 = proc do |instruction|
  instruction >= 3 ? instruction - 1 : instruction + 1
end

puts "🎄 " * 40
# puts "Iterations required in step 1: #{JumpInstructionMaze.steps_required(INPUT, incrementor: INCREMENTOR_PART_1)}"
puts "Iterations required in step 2: #{JumpInstructionMaze.steps_required(INPUT, incrementor: INCREMENTOR_PART_2)}"
puts "🎄 " * 40
