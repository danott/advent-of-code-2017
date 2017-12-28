require "minitest"
require "minitest/autorun"
require "pry"
require "awesome_print"

PUZZLE_INPUT = File.read("lib/day_23_input.txt")

class TheTest < Minitest::Test
  def test_part_1
    skip
    program = Program.parse(PUZZLE_INPUT)
    assert_equal 6724, program.call.counts["mul"]
    assert_equal 1, program.call.registers["h"]
  end

  def test_part_2
    assert_equal 903, brute_force
  end
end

class Program
  A_TO_Z = ("a".."z").to_a

  def self.parse(input)
    instructions = input.lines.map { |line| Instruction.from_line(line) }
    new(instructions: instructions)
  end

  attr_accessor :registers, :instructions, :index, :counts

  def initialize(instructions:)
    @registers = Hash.new(0)
    @counts = Hash.new(0)
    @instructions = instructions
    @index = 0
  end

  def call
    self.next until done?
    self
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
    registers[arg_x] = coerce_arg(arg_y)
    true
  end

  def sub(arg_x:, arg_y:)
    registers[arg_x] -= coerce_arg(arg_y)
    true
  end

  def mul(arg_x:, arg_y:)
    registers[arg_x] *= coerce_arg(arg_y)
    true
  end

  def jnz(arg_x:, arg_y:)
    return true if coerce_arg(arg_x).zero?
    @index += coerce_arg(arg_y)
    false
  end

  def coerce_arg(identifier)
    if identifier.is_a? Integer
      identifier
    else
      registers[identifier]
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
    new(command: command, arg_x: coerce_arg(arg_x), arg_y: coerce_arg(arg_y))
  end

  def self.coerce_arg(arg)
    if Program::A_TO_Z.include?(arg)
      arg
    else
      arg.to_i
    end
  end

  attr_reader :command, :arg_x, :arg_y

  def initialize(command:, arg_x:, arg_y:)
    @command = command
    @arg_x = arg_x
    @arg_y = arg_y
  end
end


def brute_force(puzzle_input = 84)
  b = puzzle_input * 100 + 100000
  c = b + 17000
  d = 0
  f = 0
  g = 0
  h = 0

  loop do
    f = 1
    d = 2

    loop do
      break unless d * d < b
      break f = 0 if (b % d).zero?
      d += 1
    end

    h += 1 if f.zero?
    g = b - c
    b += 17
    break if g.zero?
  end

  h
end
