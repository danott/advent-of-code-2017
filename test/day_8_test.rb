# http://adventofcode.com/2017/day/8
#
# --- Day 8: I Heard You Like Registers ---
#
# You receive a signal directly from the CPU. Because of your recent assistance with jump instructions, it would like you to compute the result of a series of unusual register instructions.
#
# Each instruction consists of several parts: the register to modify, whether to increase or decrease that register's value, the amount by which to increase or decrease it, and a condition. If the condition fails, skip the instruction without modifying the register. The registers all start at 0. The instructions look like this:
#
# b inc 5 if a > 1
# a inc 1 if b < 5
# c dec -10 if a >= 1
# c inc -20 if c == 10
# These instructions would be processed as follows:
#
# Because a starts at 0, it is not greater than 1, and so b is not modified.
# a is increased by 1 (to 1) because b is less than 5 (it is 0).
# c is decreased by -10 (to 10) because a is now greater than or equal to 1 (it is 1).
# c is increased by -20 (to -10) because c is equal to 10.
# After this process, the largest value in any register is 1.
#
# You might also encounter <= (less than or equal to) or != (not equal to). However, the CPU doesn't have the bandwidth to tell you what all the registers are named, and leaves that to you to determine.
#
# What is the largest value in any register after completing the instructions in your puzzle input?
#
# --- Part Two ---
#
# To be safe, the CPU also needs to know the highest value held in any register during this process so that it can decide how much memory to allocate to these operations. For example, in the above instructions, the highest value ever held was 10 (in register c after the third instruction was evaluated).

require "minitest"
require "minitest/autorun"
require "awesome_print"
require "pry"

class TheTest < Minitest::Test
  TEST_INPUT = <<~END
    b inc 5 if a > 1
    a inc 1 if b < 5
    c dec -10 if a >= 1
    c inc -20 if c == 10
  END

  def test_part_1
    assert_equal 1, Program.parse(TEST_INPUT).max_after_execution
  end

  def test_part_2
    assert_equal 10, Program.parse(TEST_INPUT).max_during_execution
  end

  def test_refactoring
    assert_equal 5752, Program.parse(PUZZLE_INPUT).max_after_execution
    assert_equal 6366, Program.parse(PUZZLE_INPUT).max_during_execution
  end
end

class Program
  def self.parse(input)
    instructions = input.lines.map do |line|
      instruction_register, instruction_operation, instruction_amount, _, condition_register, condition_comparison, condition_amount = line.chomp.split
      instruction_operation = case instruction_operation
                              when "inc"
                                :+
                              when "dec"
                                :-
                              end
      Instruction.new(
        register: instruction_register,
        operation: instruction_operation,
        amount: instruction_amount.to_i,
        condition: Condition.new(
          register: condition_register,
          comparison: condition_comparison,
          amount: condition_amount.to_i,
        ),
      )
    end
    new(instructions: instructions)
  end

  attr_accessor :registry, :instructions, :next_instruction_to_execute

  def initialize(registry: Hash.new(0), instructions:)
    @registry = registry
    @instructions = instructions
    @next_instruction_to_execute = 0
  end

  def next
    instructions[next_instruction_to_execute].execute(registry)
    self.next_instruction_to_execute += 1
    self
  end

  def max_after_execution
    execute
    max
  end

  def max_during_execution
    peak = 0
    until done?
      self.next
      peak = max if max > peak
    end
    peak
  end

  def max
    registry.values.max || 0
  end

  def execute
    self.next until done?
    self
  end

  def done?
    next_instruction_to_execute >= instructions.size
  end

  class Instruction
    attr_accessor :register, :operation, :amount, :condition

    def initialize(register:, operation:, amount:, condition:)
      @register = register
      @operation = operation
      @amount = amount
      @condition = condition
    end

    def execute(registry)
      registry[register] = registry[register].send(operation, amount) if condition.satisfied?(registry)
    end
  end

  class Condition
    attr_accessor :registry, :register, :comparison, :amount

    def initialize(register:, comparison:, amount:)
      @register = register
      @comparison = comparison
      @amount = amount
    end

    def satisfied?(registry)
      registry[register].send(comparison, amount)
    end
  end
end

PUZZLE_INPUT = File.read("./day_8_input.txt")

puts "🎄 " * 40
puts "The maximum value in a register after executing the program: #{Program.parse(PUZZLE_INPUT).max_after_execution}"
puts "The maximum value ever in a register while executing the program: #{Program.parse(PUZZLE_INPUT).max_during_execution}"
puts "🎄 " * 40
