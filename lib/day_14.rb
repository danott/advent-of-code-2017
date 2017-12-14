require "minitest"
require "minitest/autorun"
require "pry"
require "awesome_print"

TEST_INPUT = "flqrgnkx"
PUZZLE_INPUT = "xlqgujun"

class TheTest < Minitest::Test
  def test_part_1
    assert_equal 8108, squares_used(TEST_INPUT)
  end

  def test_part_2
    assert_equal 1242, unique_regions(TEST_INPUT)
  end

  def test_refactoring
    assert_equal 8204, squares_used(PUZZLE_INPUT)
    assert_equal 1089, unique_regions(PUZZLE_INPUT)
  end
end

def string_to_lengths(string)
  lengths = string.chars.map(&:ord)
  lengths += [17, 31, 73, 47, 23]
  lengths *= 64
end

def squares_used(input)
  build_grid(input).flatten.count(1)
end

def unique_regions(input)
  grid = build_grid(input)
  group_index = 2
  128.times do |x|
    128.times do |y|
      group_index += 1 if visit_cell(grid: grid, x: x, y: y, group_index: group_index)
    end
  end
  grid.flatten.uniq.count - 1
end

def visit_cell(grid:, x:, y:, group_index:)
  return false if x < 0 || x >= grid.size
  return false if y < 0 || y >= grid.size
  return false if grid[x][y] != 1

  grid[x][y] = group_index
  visit_cell(grid: grid, x: x - 1, y: y, group_index: group_index)
  visit_cell(grid: grid, x: x + 1, y: y, group_index: group_index)
  visit_cell(grid: grid, x: x, y: y + 1, group_index: group_index)
  visit_cell(grid: grid, x: x, y: y - 1, group_index: group_index)

  true
end

def build_grid(input)
  128.times.map do |i|
    KnotHash.new(lengths: string_to_lengths("#{input}-#{i}")).call.to_bits
  end
end

class KnotHash
  attr_accessor :rotating_list, :current_position, :skip_size, :lengths

  BINARY = {
    "0" => "0000",
    "1" => "0001",
    "2" => "0010",
    "3" => "0011",
    "4" => "0100",
    "5" => "0101",
    "6" => "0110",
    "7" => "0111",
    "8" => "1000",
    "9" => "1001",
    "a" => "1010",
    "b" => "1011",
    "c" => "1100",
    "d" => "1101",
    "e" => "1110",
    "f" => "1111",
  }.freeze

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

  def to_bits
    to_s.chars.map { |c| BINARY.fetch(c).chars }.flatten.map(&:to_i)
  end
end