require "minitest"
require "minitest/autorun"
require "pry"
require "awesome_print"

BEGINNING_SQUARE = ".#./..#/###"
TEST_INPUT = File.read("lib/day_21_test_input.txt")
PUZZLE_INPUT = File.read("lib/day_21_puzzle_input.txt")

class TheTest < Minitest::Test
  def test_part_1
    root = PixelSquare.from_s(BEGINNING_SQUARE)
    transformer = Transformer.parse(TEST_INPUT)
    2.times { root = iterate(root, transformer) }
    assert_equal 12, root.count
  end

  def test_part_2
  end

  def test_execute_part_1
    root = PixelSquare.from_s(BEGINNING_SQUARE)
    transformer = Transformer.parse(PUZZLE_INPUT)
    5.times { root = iterate(root, transformer) }
    assert_equal 12, root.count
  end
end

def iterate(pixel_square, transformer)
  size = pixel_square.size
  if (size % 2).zero?
    rows_of_four = pixel_square.pixels.each_slice(size * 2).map do |major_row|
      (size / 2).times.map do |i|
        i = i * 2
        transformer.call(PixelSquare.new(major_row.values_at(i, i + 1, i + size, i + size + 1)))
      end
    end
    ordered_pixels = rows_of_four.map do |major_row|
      one = major_row.map { |col| col.row(0) }
      two = major_row.map { |col| col.row(1) }
      three = major_row.map { |col| col.row(2) }
      [one, two, three].join
    end
    PixelSquare.new(ordered_pixels.join.chars)
  elsif (pixel_square.size % 3).zero?
    rows_of_four = pixel_square.pixels.each_slice(size * 3).map do |major_row|
      (size / 3).times.map do |i|
        i = i * 3
        transformer.call(PixelSquare.new(major_row.values_at(i, i + 1, i + 2, i + size, i + size + 1, i + size + 2, i + size + size, i + size + size + 1, i + size + size + 2)))
      end
    end
    ordered_pixels = rows_of_four.map do |major_row|
      one = major_row.map { |col| col.row(0) }
      two = major_row.map { |col| col.row(1) }
      three = major_row.map { |col| col.row(2) }
      four = major_row.map { |col| col.row(3) }
      [one, two, three, four].join
    end
    PixelSquare.new(ordered_pixels.join.chars)
  else
    fail
  end
end

class Transformer
  def self.parse(puzzle_input)
    transformations = puzzle_input.lines.reduce({}) do |a, line|
      key, value = line.split("=>")
      a[key.strip] = PixelSquare.from_s(value.strip)
      a
    end

    new(transformations)
  end

  attr_reader :transformations

  def initialize(transformations)
    @transformations = transformations
  end

  def call(pixel_square)
    key = transformations.keys.find { |k| permutations(pixel_square).include?(k) }
    binding.pry if key.nil?
    transformations.fetch(key)
  end

  def permutations(pixel_square)
    [
      pixel_square.to_s,
      pixel_square.flip_horizontally.to_s,
      pixel_square.flip_vertically.to_s,
      pixel_square.rotate_right.to_s,
      pixel_square.rotate_right.flip_horizontally.to_s,
      pixel_square.rotate_right.flip_vertically.to_s,
      pixel_square.rotate_right.rotate_right.to_s,
      pixel_square.rotate_right.rotate_right.flip_horizontally.to_s,
      pixel_square.rotate_right.rotate_right.flip_vertically.to_s,
      pixel_square.rotate_right.rotate_right.rotate_right.to_s,
      pixel_square.rotate_right.rotate_right.rotate_right.flip_horizontally.to_s,
      pixel_square.rotate_right.rotate_right.rotate_right.flip_vertically.to_s,
    ]
  end
end

class PixelSquare
  attr_reader :pixels

  def self.from_s(string)
    pixels = string.chars.select { |c| %w(# .).include?(c) }
    new(pixels)
  end

  def initialize(pixels)
    @pixels = pixels
  end

  def row(i)
    pixels.each_slice(size).to_a[i]
  end

  def size
    Math.sqrt(pixels.size).floor
  end

  def to_s
    pixels.each_slice(size).map(&:join).join("/")
  end

  # [0, 1, 2, => [6, 3, 0,
  #  3, 4, 5,     7, 4, 1,
  #  6, 7, 8]     8, 5, 2]
  #
  # [0, 1, => [2, 0,
  #  2, 3]     3, 1]
  def rotate_right
    case size
    when 3
      self.class.new(pixels.values_at(6, 3, 0, 7, 4, 1, 8, 5, 2))
    when 2
      self.class.new(pixels.values_at(2, 0, 3, 1))
    else
      fail
    end
  end

  # [0, 1, 2, => [6, 7, 8,
  #  3, 4, 5,     3, 4, 5,
  #  6, 7, 8]     0, 1, 2]
  #
  # [0, 1, => [2, 3,
  #  2, 3]     0, 1,
  def flip_horizontally
    case size
    when 3
      self.class.new(pixels.values_at(6, 7, 8, 3, 4, 5, 0, 1, 2))
    when 2
      self.class.new(pixels.values_at(2, 3, 0, 1))
    else
      fail
    end
  end

  # [0, 1, 2, => [2, 1, 0,
  #  3, 4, 5,     5, 4, 3,
  #  6, 7, 8]     8, 7, 6]
  #
  # [0, 1, => [1, 0,
  #  2, 3]     3, 2,
  def flip_vertically
    case size
    when 3
      self.class.new(pixels.values_at(2, 1, 0, 5, 4, 3, 8, 7, 6))
    when 2
      self.class.new(pixels.values_at(1, 0, 3, 2))
    else
      fail
    end
  end

  def ==(other)
    to_s == other.to_s
  end

  def count
    pixels.count("#")
  end
end
