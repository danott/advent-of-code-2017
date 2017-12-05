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
    maze.next until maze.escaped?
    maze.iterations
  end

  def self.parse(string, incrementor:)
    instructions = string.split.map(&:to_i)
    self.new(instructions: instructions, incrementor: incrementor)
  end

  attr_reader :instructions, :cursor, :incrementor, :iterations

  def initialize(instructions:, incrementor:)
    @instructions = instructions
    @incrementor = incrementor
    @cursor = 0
    @iterations = 0
  end

  def next
    return self if escaped?
    instruction_was = instructions[cursor]
    instructions[cursor] = incrementor.call(instruction_was)
    @cursor += instruction_was
    @iterations += 1
    self
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
puts "Iterations required in step 1: #{JumpInstructionMaze.steps_required(INPUT, incrementor: INCREMENTOR_PART_1)}"
puts "Iterations required in step 2: #{JumpInstructionMaze.steps_required(INPUT, incrementor: INCREMENTOR_PART_2)}"
puts "🎄 " * 40
