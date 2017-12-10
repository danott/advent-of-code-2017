require "minitest"
require "minitest/autorun"
require "pry"
require "awesome_print"

PUZZLE_INPUT = "88,88,211,106,141,1,78,254,2,111,77,255,90,0,54,205"

class TheTest < Minitest::Test
  def test_part_1
    instance = KnotHash.new(size: 5, lengths: [3, 4, 1, 5])
    assert_equal 0, instance.current_position
    assert_equal 0, instance.skip_size
    assert_equal [0, 1, 2, 3, 4], instance.sparse_hash

    instance.next
    assert_equal 3, instance.current_position
    assert_equal 1, instance.skip_size
    assert_equal [2, 1, 0, 3, 4], instance.sparse_hash

    instance.next
    assert_equal 3, instance.current_position
    assert_equal 2, instance.skip_size
    assert_equal [4, 3, 0, 1, 2], instance.sparse_hash

    instance.next
    assert_equal 1, instance.current_position
    assert_equal 3, instance.skip_size
    assert_equal [4, 3, 0, 1, 2], instance.sparse_hash

    instance.next
    assert_equal 4, instance.current_position
    assert_equal 4, instance.skip_size
    assert_equal [3, 4, 2, 1, 0], instance.sparse_hash

    lengths = PUZZLE_INPUT.split(",").map(&:to_i)
    knot_hash = KnotHash.new(lengths: lengths).call
    assert_equal 11375, knot_hash.sparse_hash.take(2).reduce(:*)
  end

  def test_part_2
    lengths = PUZZLE_INPUT.chars.map(&:ord)
    lengths += [17, 31, 73, 47, 23]
    lengths *= 64
    assert_equal "e0387e2ad112b7c2ef344e44885fe4d8", KnotHash.new(lengths: lengths).call.to_s
  end
end

class KnotHash
  attr_accessor :rotating_list, :current_position, :skip_size, :lengths

  def initialize(size: 256, lengths:)
    @rotating_list = (0...size).to_a
    @current_position = 0
    @skip_size = 0
    @lengths = lengths
  end

  def next
    length = lengths.shift
    reversed_section = rotating_list.shift(length).reverse
    rotating_list.push(*reversed_section)
    self.current_position += length

    skip_size.times do
      self.current_position += 1
      rotating_list.push rotating_list.shift
    end

    self.current_position %= rotating_list.size
    self.skip_size += 1
    self
  end

  def sparse_hash
    copy = rotating_list.dup
    copy.unshift(*copy.pop(current_position))
  end

  def call
    self.next until done?
    self
  end

  def done?
    lengths.empty?
  end

  def dense_hash
    sparse_hash.each_slice(16).map { |numbers| numbers.reduce(&:^) }
  end

  def to_s
    dense_hash.reduce("") { |a, e| a + e.to_s(16).rjust(2, "0") }
  end
end