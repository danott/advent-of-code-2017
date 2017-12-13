require "minitest"
require "minitest/autorun"
require "pry"
require "awesome_print"

PUZZLE_INPUT = File.read("lib/day_13_input.txt")
TEST_INPUT = <<~END
  0: 3
  1: 2
  4: 4
  6: 4
END

class TheTest < Minitest::Test
  def test_part_1
    assert_equal 24, severity_of_trip(TEST_INPUT)
  end

  def test_part_2
    assert_equal 10, delay_for_safe_travel(TEST_INPUT)
  end

  def test_refactoring
    skip "Calculating the delay is extremely slow"
    assert_equal 1300, severity_of_trip(PUZZLE_INPUT)
    assert_equal 3870382, delay_for_safe_travel(PUZZLE_INPUT)
  end
end

def severity_of_trip(puzzle_input)
  Firewall.parse(puzzle_input).severity
end

def delay_for_safe_travel(puzzle_input)
  firewall = Firewall.parse(puzzle_input)
  firewall.next until firewall.safe?
  firewall.delay
end

class Firewall
  def self.parse(puzzle_input)
    columns = puzzle_input.lines.map do |line|
      depth, range = line.split(": ").map(&:to_i)
      FirewallColumn.new(depth: depth, range: range)
    end
    new(columns: columns)
  end

  attr_reader :columns, :delay

  def initialize(columns:, delay: 0)
    @delay = delay
    @columns = columns
  end

  def next
    @delay = delay.next
    columns.each(&:next)
  end

  def safe?
    columns.all?(&:safe?)
  end

  def severity
    columns.reject(&:safe?).map(&:severity).reduce(&:+)
  end
end

class FirewallColumn
  attr_reader :depth, :range, :position

  def initialize(depth:, range:)
    @depth = depth
    @range = range
    @position = cycle.next
    depth.times { self.next }
  end

  def next
    @position = cycle.next
    self
  end

  def safe?
    !position.zero?
  end

  def severity
    depth * range
  end

  private

  def cycle
    return @cycle if defined? @cycle
    forwards = (0...range).to_a
    backwards = forwards.dup.reverse
    backwards.shift
    backwards.pop
    @cycle = (forwards + backwards).cycle
  end
end


