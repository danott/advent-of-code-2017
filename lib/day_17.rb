require "minitest"
require "minitest/autorun"
require "pry"
require "awesome_print"

class TheTest < Minitest::Test
  def test_part_1
    s = Spinlock.new(step: 3)
    assert_equal [0], s.state
    assert_equal [0, 1], s.next.state
    assert_equal [0, 2, 1], s.next.state
    assert_equal [0, 2, 3, 1], s.next.state
    assert_equal [0, 2, 4, 3, 1], s.next.state
    assert_equal [0, 5, 2, 4, 3, 1], s.next.state
    assert_equal [0, 5, 2, 4, 3, 6, 1], s.next.state
    assert_equal [0, 5, 7, 2, 4, 3, 6, 1], s.next.state
    assert_equal [0, 5, 7, 2, 4, 3, 8, 6, 1], s.next.state
    assert_equal [0, 9, 5, 7, 2, 4, 3, 8, 6, 1], s.next.state

    s = Spinlock.new(step: 303)
    s.next until s.state.size > 2017
    assert_equal 1971, s.state[s.state.index(2017) + 1]
  end

  def test_part_2
    # Taking advantage of 0 index is always zero in the circle.
    s = StupidLock.new(step: 303)
    s.next until s.size > 50_000_000
    assert_equal 17202899, s.last_insert_at_index_1
  end
end

class Spinlock
  attr_reader :step, :position, :state

  def initialize(step:, position: 0, state: [0])
    @step = step
    @position = position
    @state = state
  end

  def next
    @position = ((position + step) % state.size) + 1
    state.insert(position, state.size)
    self
  end
end

class StupidLock
  attr_reader :step, :position, :size, :last_insert_at_index_1

  def initialize(step:, position: 0, size: 1)
    @step = step
    @position = position
    @size = size
  end

  def next
    @position = ((position + step) % size) + 1
    @last_insert_at_index_1 = size if position == 1
    @size += 1
    self
  end
end