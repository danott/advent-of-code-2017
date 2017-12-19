require "minitest"
require "minitest/autorun"
require "pry"
require "awesome_print"

PUZZLE_INPUT = File.read("lib/day_18_input.txt")

class TheTest < Minitest::Test
  def test_part_1
    program = Program.parse(PUZZLE_INPUT)

    sound_bank = []
    last_sound_bank = sound_bank.clone

    program.channel_out = sound_bank
    program.channel_in = sound_bank

    while last_sound_bank.size <= sound_bank.size
      last_sound_bank = sound_bank.clone
      program.next
    end

    assert_equal 3423, last_sound_bank.last
  end

  def test_part_2
    coordinator = Coordinator.new(
      program0: Program.parse(PUZZLE_INPUT),
      program1: Program.parse(PUZZLE_INPUT),
    )

    coordinator.next until coordinator.done?

    assert_equal 7493, coordinator.program1.sends
  end
end

class Coordinator
  attr_reader :program0, :program1

  def initialize(program0:, program1:)
    program0.channel_out = []
    program1.channel_out = []
    program0.channel_in = program1.channel_out
    program1.channel_in = program0.channel_out
    program0.state["p"] = 0
    program1.state["p"] = 1
    @program0 = program0
    @program1 = program1
  end

  def done?
    program0.done? || program1.done? || deadlock?
  end

  def next
    program0.next
    program1.next
  end

  private

  def deadlock?
    program0.lock? && program1.lock?
  end
end

class Program
  A_TO_Z = ("a".."z").to_a

  def self.parse(input)
    instructions = input.lines.map { |line| Instruction.from_line(line) }
    new(instructions: instructions)
  end

  attr_accessor :state, :channel_out, :channel_in, :instructions, :index, :sends

  def initialize(instructions:)
    @state = Hash.new(0)
    @instructions = instructions
    @index = 0
    @sends = 0
  end

  def next
    return self if done? || lock?
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

  def lock?
    return false if next_instruction.nil?
    next_instruction.command == "rcv" && channel_in.size.zero?
  end

  private

  def set(arg_x:, arg_y:)
    state[arg_x] = coerce_arg(arg_y)
    true
  end

  def add(arg_x:, arg_y:)
    state[arg_x] += coerce_arg(arg_y)
    true
  end

  def mul(arg_x:, arg_y:)
    state[arg_x] *= coerce_arg(arg_y)
    true
  end

  def mod(arg_x:, arg_y:)
    state[arg_x] %= coerce_arg(arg_y)
    true
  end

  def snd(arg_x:, **_)
    @sends += 1
    channel_out.push(coerce_arg(arg_x))
    true
  end

  def rcv(arg_x:, **_)
    return false if channel_in.size.zero?
    state[arg_x] = channel_in.shift
    true
  end

  def jgz(arg_x:, arg_y:)
    return true unless coerce_arg(arg_x).positive?
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
