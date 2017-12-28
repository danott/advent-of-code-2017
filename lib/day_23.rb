require "minitest"
require "minitest/autorun"
require "pry"
require "awesome_print"

PUZZLE_INPUT = File.read("lib/day_23_input.txt")

class TheTest < Minitest::Test
  def test_part_1
    program = Program.parse(PUZZLE_INPUT)
    program.state["a"] = 1
    program.next until program.done?
    ap program.state
  end

  def test_part_2
  end
end

class Program
  A_TO_Z = ("a".."z").to_a

  def self.parse(input)
    instructions = input.lines.map { |line| Instruction.from_line(line) }
    new(instructions: instructions)
  end

  attr_accessor :state, :instructions, :index, :counts

  def initialize(instructions:)
    @state = Hash.new(0)
    @counts = Hash.new(0)
    @instructions = instructions
    @index = 0
  end

  def next
    return self if done?
    counts[next_instruction.command] += 1
    @index += 1 if send(
      next_instruction.command,
      arg_x: next_instruction.arg_x,
      arg_y: next_instruction.arg_y,
    )
    self
  end

  def done?
    next_instruction.nil?
  end

  private

  def set(arg_x:, arg_y:)
    state[arg_x] = coerce_arg(arg_y)
    true
  end

  def sub(arg_x:, arg_y:)
    state[arg_x] -= coerce_arg(arg_y)
    true
  end

  def mul(arg_x:, arg_y:)
    state[arg_x] *= coerce_arg(arg_y)
    true
  end

  def jnz(arg_x:, arg_y:)
    return true if coerce_arg(arg_x).zero?
    @index += coerce_arg(arg_y)
    false
  end

  def coerce_arg(identifier)
    if A_TO_Z.include?(identifier)
      state[identifier]
    else
      identifier.to_i
    end
  end

  def next_instruction
    return if index.negative? || index >= instructions.size
    instructions[index]
  end
end

class Instruction
  def self.from_line(line)
    command, arg_x, arg_y = line.split
    new(command: command, arg_x: arg_x, arg_y: arg_y)
  end

  attr_reader :command, :arg_x, :arg_y

  def initialize(command:, arg_x:, arg_y:)
    @command = command
    @arg_x = arg_x
    @arg_y = arg_y
  end
end
