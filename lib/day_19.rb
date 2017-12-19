require "minitest"
require "minitest/autorun"
require "pry"
require "awesome_print"

TEST_INPUT = File.read("lib/day_19_test_input.txt")
PUZZLE_INPUT = File.read("lib/day_19_puzzle_input.txt")

class TheTest < Minitest::Test
  def test_part_1
    assert_equal "ABCDEF", sights_seen(TEST_INPUT)
  end

  def test_part_2
    assert_equal 38, total_steps(TEST_INPUT)
  end

  def test_refactoring
    skip
    assert_equal "RYLONKEWB", sights_seen(PUZZLE_INPUT)
    assert_equal 16016, total_steps(PUZZLE_INPUT)
  end
end

def sights_seen(input)
  w = Walkabout.new(graph: Graph.parse(input))
  w.next until w.done?
  w.sights.join
end

def total_steps(input)
  w = Walkabout.new(graph: Graph.parse(input))
  w.next until w.done?
  w.count
end

class Walkabout
  A_TO_Z = ("A".."Z").freeze

  attr_reader :graph, :current_node, :prev_node, :sights, :count

  def initialize(graph:)
    @graph = graph
    @prev_node = nil
    @current_node = graph.nodes.find { |n| n.neighbors.size == 1 }
    @count = 1
    @sights = []
  end

  def next
    current_node_was = current_node

    @current_node = next_node
    @prev_node = current_node_was
    @sights << current_node.value if A_TO_Z.include? current_node.value
    @count += 1

    self
  end

  def done?
    next_node.nil?
  end

  private

  def next_node
    current_node.next(prev_node)
  end
end

class Graph
  def self.parse(input)
    graph = new

    graph.nodes = input.lines.map(&:chomp).map(&:chars).each_with_index.map do |row, row_index|
      row.each_with_index.map do |value, col_index|
        unless [" ", "", nil].include?(value)
          Node.new(value: value, graph: graph, row_index: row_index, col_index: col_index)
        end
      end
    end

    graph.nodes.flatten!.compact!

    graph
  end

  attr_accessor :nodes

  def initialize(nodes: [])
    @nodes = nodes
  end

  def neighbors(row_index:, col_index:)
    north = nodes.find { |n| n.row_index == row_index + 1 && n.col_index == col_index }
    south = nodes.find { |n| n.row_index == row_index - 1 && n.col_index == col_index }
    east = nodes.find { |n| n.row_index == row_index && n.col_index == col_index + 1 }
    west = nodes.find { |n| n.row_index == row_index && n.col_index == col_index + -1 }

    [north, south, west, east].compact
  end

  private

  def height
    @height ||= nodes.size
  end

  def width
    @width ||= nodes.map(&:size).max
  end
end

class Node
  attr_reader :value, :graph, :row_index, :col_index

  def initialize(value:, graph:, row_index:, col_index:)
    @value = value == " " ? nil : value
    @graph = graph
    @row_index = row_index
    @col_index = col_index
  end

  def neighbors
    @neighbors ||= graph.neighbors(row_index: row_index, col_index: col_index)
  end

  def next(prev_node)
    candidates = neighbors - [prev_node]
    return candidates.first if candidates.size == 1
    candidates.find { |n| n.row_index == prev_node.row_index || n.col_index == prev_node.col_index }
  end

  def inspect
    "#<Node: [#{row_index}, #{col_index}] => '#{value}'"
  end
end
