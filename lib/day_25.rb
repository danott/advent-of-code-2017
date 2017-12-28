require "minitest"
require "minitest/autorun"
require "pry"
require "awesome_print"

class TheTest < Minitest::Test
  def test_part_1
    assert_equal 2832, State.new.call.checksum
  end
end

# Begin in state A.
# Perform a diagnostic checksum after 12794428 steps.

class State
  A = "a".freeze
  B = "b".freeze
  C = "c".freeze
  D = "d".freeze
  E = "e".freeze
  F = "f".freeze

  attr_reader :state, :tape, :cursor, :iterations

  def initialize(state: A, tape: Hash.new(0), cursor: 0, iterations: 12794428)
    @state = state
    @tape = tape
    @cursor = cursor
    @iterations = iterations
  end

  def value
    tape[cursor]
  end

  def call
    self.next until iterations.zero?
    self
  end

  def next
    return self if iterations.zero?
    @iterations -= 1
    next_value, next_direction, next_state = send("next_from_state_#{state}")
    @tape[cursor] = next_value
    @cursor += next_direction
    @state = next_state
    self
  end

  def checksum
    tape.values.reduce(&:+)
  end

  private

  # In state A:
  #   If the current value is 0:
  #     - Write the value 1.
  #     - Move one slot to the right.
  #     - Continue with state B.
  #   If the current value is 1:
  #     - Write the value 0.
  #     - Move one slot to the left.
  #     - Continue with state F.
  def next_from_state_a
    if value.zero?
      [1, 1, B]
    else
      [0, -1, F]
    end
  end

  # In state B:
  #   If the current value is 0:
  #     - Write the value 0.
  #     - Move one slot to the right.
  #     - Continue with state C.
  #   If the current value is 1:
  #     - Write the value 0.
  #     - Move one slot to the right.
  #     - Continue with state D.
  def next_from_state_b
    if value.zero?
      [0, 1, C]
    else
      [0, 1, D]
    end
  end

  # In state C:
  #   If the current value is 0:
  #     - Write the value 1.
  #     - Move one slot to the left.
  #     - Continue with state D.
  #   If the current value is 1:
  #     - Write the value 1.
  #     - Move one slot to the right.
  #     - Continue with state E.
  def next_from_state_c
    if value.zero?
      [1, -1, D]
    else
      [1, 1, E]
    end
  end

  # In state D:
  #   If the current value is 0:
  #     - Write the value 0.
  #     - Move one slot to the left.
  #     - Continue with state E.
  #   If the current value is 1:
  #     - Write the value 0.
  #     - Move one slot to the left.
  #     - Continue with state D.
  def next_from_state_d
    if value.zero?
      [0, -1, E]
    else
      [0, -1, D]
    end
  end

  # In state E:
  #   If the current value is 0:
  #     - Write the value 0.
  #     - Move one slot to the right.
  #     - Continue with state A.
  #   If the current value is 1:
  #     - Write the value 1.
  #     - Move one slot to the right.
  #     - Continue with state C.
  def next_from_state_e
    if value.zero?
      [0, 1, A]
    else
      [1, 1, C]
    end
  end

  # In state F:
  #   If the current value is 0:
  #     - Write the value 1.
  #     - Move one slot to the left.
  #     - Continue with state A.
  #   If the current value is 1:
  #     - Write the value 1.
  #     - Move one slot to the right.
  #     - Continue with state A.
  def next_from_state_f
    if value.zero?
      [1, -1, A]
    else
      [1, 1, A]
    end
  end
end