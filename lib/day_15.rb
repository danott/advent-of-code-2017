require "minitest"
require "minitest/autorun"
require "pry"
require "awesome_print"

class TheTest < Minitest::Test
  def test_part_1
    skip
    a = Generator.new(start: 65, factor: 16807)
    b = Generator.new(start: 8921, factor: 48271)

    assert_equal 1092455, a.next
    assert_equal 430625591, b.next

    assert_equal 1181022009, a.next
    assert_equal 1233683848, b.next

    assert_equal 245556042, a.next
    assert_equal 1431495498, b.next

    assert_equal 1744312007, a.next
    assert_equal 137874439, b.next

    assert_equal 1352636452, a.next
    assert_equal 285222916, b.next

    a = Generator.new(start: 65, factor: 16807)
    b = Generator.new(start: 8921, factor: 48271)
    t = TwinGenerators.new(a: a, b: b)

    5.times { t.next }
    assert_equal 1, t.pairs

    (40_000_000 - 5).times { t.next }
    assert_equal 588, t.pairs
  end

  def test_part_2
    skip
    a = Generator.new(start: 65, factor: 16807, secondary_factor: 4)
    b = Generator.new(start: 8921, factor: 48271, secondary_factor: 8)
    t = TwinGenerators.new(a: a, b: b)

    assert_equal 1352636452, a.next
    assert_equal 1233683848, b.next

    assert_equal 1992081072, a.next
    assert_equal 862516352, b.next

    assert_equal 530830436, a.next
    assert_equal 1159784568, b.next

    assert_equal 1980017072, a.next
    assert_equal 1616057672, b.next

    assert_equal 740335192, a.next
    assert_equal 412269392, b.next

    (5_000_000 - 5).times { t.next }
    assert_equal 309, t.pairs
  end

  def test_refactoring_1
    skip
    a = Generator.new(start: 634, factor: 16807)
    b = Generator.new(start: 301, factor: 48271)
    t = TwinGenerators.new(a: a, b: b)
    40_000_000.times { t.next }
    assert_equal 588, t.pairs
  end

  def test_refactoring_2
    skip
    a = Generator.new(start: 634, factor: 16807, secondary_factor: 4)
    b = Generator.new(start: 301, factor: 48271, secondary_factor: 8)
    t = TwinGenerators.new(a: a, b: b)
    5_000_000.times { t.next }
    assert_equal 294, t.pairs
  end
end

class TwinGenerators
  attr_reader :pairs

  def initialize(a:, b:)
    @a = a
    @b = b
    @pairs = 0
  end

  def next
    compare(@a.next, @b.next)
    self
  end

  private

  def compare(left, right)
    left = left.to_s(2)[-16, 16]
    right = right.to_s(2)[-16, 16]
    @pairs += 1 if left == right
  end
end

class Generator
  def initialize(start:, factor:, secondary_factor: 1)
    @prev = start
    @factor = factor
    @secondary_factor = secondary_factor
  end

  def next
    @prev = (@prev * @factor) % 2147483647

    if (@prev % @secondary_factor).zero?
      @prev
    else
      self.next
    end
  end
end
