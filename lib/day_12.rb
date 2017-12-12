require "minitest"
require "minitest/autorun"
require "pry"
require "awesome_print"

PUZZLE_INPUT = File.read("lib/day_12_input.txt")
TEST_INPUT = <<~PIPES
  0 <-> 2
  1 <-> 1
  2 <-> 0, 3, 4
  3 <-> 2, 4
  4 <-> 2, 3, 6
  5 <-> 6
  6 <-> 4, 5
PIPES

class TheTest < Minitest::Test
  def test_part_1
    network = Network.parse(TEST_INPUT)
    group_ids = network.pipes[0].group_ids
    assert_equal [0, 2, 3, 4, 5, 6], group_ids

    group_ids = network.pipes[3].group_ids
    assert_equal [0, 2, 3, 4, 5, 6], group_ids
  end

  def test_part_2
    network = Network.parse(TEST_INPUT)
    assert_equal 2, network.groups.count
  end

  def test_refactoring
    assert_equal 152, Network.parse(PUZZLE_INPUT).pipes[0].group_ids.count
    assert_equal 186, Network.parse(PUZZLE_INPUT).groups.count
  end
end

class Network
  def self.parse(puzzle_input)
    lines = puzzle_input.lines
    pipes = lines.count.times.map { |index| Pipe.new(id: index) }
    lines.each do |line|
      line = line.split
      pipe_id = line.shift.to_i
      line.shift
      neighbor_ids = line.join.split(",").map(&:to_i)
      neighbor_ids.each do |neighbor_id|
        pipes[pipe_id].neighbors << pipes[neighbor_id]
      end
    end
    new(pipes: pipes)
  end

  attr_reader :pipes

  def initialize(pipes:)
    @pipes = pipes
  end

  def groups
    pipes.group_by(&:group_ids).keys
  end
end

class Pipe
  attr_reader :id, :neighbors

  def initialize(id:, neighbors: [])
    @id = id
    @neighbors = neighbors
  end

  def group_ids
    pipes_in_group.map(&:id).sort
  end

  private

  def pipes_in_group
    pipes_awaiting_visit = neighbors.clone
    pipes_visited = [self]

    until pipes_awaiting_visit.empty?
      pipe = pipes_awaiting_visit.shift
      pipes_visited << pipe
      pipe.neighbors.each do |n|
        next if pipes_awaiting_visit.include?(n) || pipes_visited.include?(n)
        pipes_awaiting_visit << n
      end
    end

    pipes_visited.uniq
  end
end

puts "🎄 " * 40
puts "Number of programs in the 0 group: #{Network.parse(PUZZLE_INPUT).pipes[0].group_ids.count}"
puts "Number of groups in the network: #{Network.parse(PUZZLE_INPUT).groups.count}"
puts "🎄 " * 40
