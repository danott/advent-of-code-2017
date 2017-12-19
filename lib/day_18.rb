require "minitest"
require "minitest/autorun"
require "pry"
require "awesome_print"

TEST_INPUT = <<~TEST
set a 1
add a 2
mul a a
mod a 5
snd a
set a 0
rcv a
jgz a -1
set a 1
jgz a -2
TEST

PUZZLE_INPUT = <<~END
set i 31
set a 1
mul p 17
jgz p p
mul a 2
add i -1
jgz i -2
add a -1
set i 127
set p 618
mul p 8505
mod p a
mul p 129749
add p 12345
mod p a
set b p
mod b 10000
snd b
add i -1
jgz i -9
jgz a 3
rcv b
jgz b -1
set f 0
set i 126
rcv a
rcv b
set p a
mul p -1
add p b
jgz p 4
snd a
set a b
jgz 1 3
snd b
set f 1
add i -1
jgz i -11
snd a
jgz f -16
jgz a -19
END

class TheTest < Minitest::Test
  def test_part_1
    p = Program.parse(PUZZLE_INPUT)
    sound_bank = []
    p.send_to = sound_bank
    p.receive_from = sound_bank

    last_sound_bank = sound_bank.dup

    while last_sound_bank.length <= sound_bank.length
      last_sound_bank = sound_bank.dup
      p.next
    end

    assert_equal 3423, last_sound_bank.last
  end

  def test_part_2
    test_input = <<~TEST
      snd 1
      snd 2
      snd p
      rcv a
      rcv b
      rcv c
      rcv d
    TEST
    program_0_to_program_1 = []
    program_1_to_program_0 = []

    program_0 = Program.parse(PUZZLE_INPUT)
    program_1 = Program.parse(PUZZLE_INPUT)

    program_0.state["p"] = 0
    program_1.state["p"] = 1

    program_0.send_to = program_0_to_program_1
    program_0.receive_from = program_1_to_program_0

    program_1.send_to = program_1_to_program_0
    program_1.receive_from = program_0_to_program_1

    until program_0.done? || program_1.done? || (program_0.lock? && program_1.lock?)
      program_0.next
      program_1.next
    end

    assert_equal 7493, program_1.sends
  end
end

class Program
  A_TO_Z = ("a".."z").to_a

  def self.parse(input)
    instructions = input.lines.map { |line| Instruction.from_line(line) }
    new(instructions: instructions)
  end

  attr_accessor :state, :send_to, :receive_from, :instructions, :index, :sends

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
    next_instruction.command == "rcv" && receive_from.size.zero?
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
    send_to.push(coerce_arg(arg_x))
    true
  end

  def rcv(arg_x:, **_)
    return false if receive_from.size.zero?
    state[arg_x] = receive_from.shift
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
