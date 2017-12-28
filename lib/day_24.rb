require "minitest"
require "minitest/autorun"
require "pry"
require "awesome_print"

TEST_INPUT = File.read("lib/day_24_test_input.txt")
PUZZLE_INPUT = File.read("lib/day_24_puzzle_input.txt")

class TheTest < Minitest::Test
  def test_part_1
    test_ports = Port.parse_all(TEST_INPUT.lines)
    assert_equal 31, strongest_bridge(test_ports)
  end

  def test_part_2
    test_ports = Port.parse_all(TEST_INPUT.lines)
    assert_equal 19, strongest_longest_bridge(test_ports)
  end

  def test_results_1
    skip
    puzzle_ports = Port.parse_all(PUZZLE_INPUT.lines)
    assert_equal 1859, strongest_bridge(puzzle_ports)
  end

  def test_results_2
    skip
    puzzle_ports = Port.parse_all(PUZZLE_INPUT.lines)
    assert_equal 1799, strongest_longest_bridge(puzzle_ports)
  end
end

def strongest_longest_bridge(all_the_ports)
  start = Bridge.new
  start.ports << Port.new(left: 0, right: 0)
  all_bridges = build_bridges(in_progress: start, ports: all_the_ports)
  longest = all_bridges.map(&:length).max
  longest = all_bridges.select { |b| b.length == longest }
  longest.map(&:strength).max
end

def strongest_bridge(all_the_ports)
  start = Bridge.new
  start.ports << Port.new(left: 0, right: 0)
  all_bridges = build_bridges(in_progress: start, ports: all_the_ports)
  all_bridges.map(&:strength).max
end

def build_bridges(in_progress:, ports:)
  candidates = ports.select { |p| [p.left, p.right].include?(in_progress.end) }.uniq
  return [in_progress] if candidates.empty?

  bridges = candidates.map do |c|
    next_ports = ports.dup
    next_ports.delete_at(next_ports.index(c))
    c = c.reverse if in_progress.end != c.left
    next_in_progress = Bridge.new(ports: in_progress.ports + [c])
    build_bridges(in_progress: next_in_progress, ports: next_ports)
  end

  bridges.flatten
end

class Bridge
  attr_reader :ports

  def initialize(ports: [])
    @ports = ports
  end

  def begin
    ports.first.left
  end

  def end
    ports.last.right
  end

  def length
    ports.length
  end

  def strength
    ports.reduce(0) do |m, p|
      m + p.left + p.right
    end
  end
end

class Port
  attr_reader :left, :right

  def self.parse_all(lines)
    lines.map { |l| parse(l) }
  end

  def self.parse(line)
    left, right = line.chomp.split("/").map(&:to_i)
    Port.new(left: left, right: right)
  end

  def initialize(left:, right:)
    @left = left
    @right = right
  end

  def reverse
    self.class.new(left: right, right: left)
  end

  def ==(other)
    [left, right] == [other.left, other.right]
  end
end
