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
    skip
    assert_equal 1300, severity_of_trip(PUZZLE_INPUT)
    assert_equal 3870382, delay_for_safe_travel(PUZZLE_INPUT)
  end
end

def severity_of_trip(puzzle_input)
  firewall_columns = puzzle_input.lines.map do |line|
    depth, range = line.split(": ").map(&:to_i)
    FirewallColumn.new(depth: depth, range: range).call
  end
  firewall_columns = firewall_columns.select { |f| f.position.zero? }
  firewall_columns.map(&:severity).reduce(&:+)
end

def delay_for_safe_travel(puzzle_input)
  firewall = Firewall.parse(puzzle_input)
  firewall.next until firewall.safe?
  firewall.columns.first.time
end

class Firewall
  def self.parse(puzzle_input)
    columns = puzzle_input.lines.map do |line|
      depth, range = line.split(": ").map(&:to_i)
      FirewallColumn.new(depth: depth, range: range).call
    end
    new(columns: columns)
  end

  attr_reader :columns
  def initialize(columns:)
    @columns = columns
  end

  def next
    columns.each(&:next)
  end

  def safe?
    columns.all?(&:safe?)
  end
end

class FirewallColumn
  attr_reader :depth, :range, :position, :time

  def initialize(depth:, range:)
    @depth = depth
    @range = range
    @position = cycle.next
    @time = 0
  end

  def next
    @position = cycle.next
    @time = time.next
    self
  end

  def call
    self.next until done?
    self
  end

  def done?
    time == depth
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


