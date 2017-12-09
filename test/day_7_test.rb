#
require "minitest"
require "minitest/autorun"
require "pry"

PUZZLE_INPUT = File.read("./day_7_input.txt")

class TheTest < Minitest::Test
  TEST_INPUT = <<~END
    pbga (66)
    xhth (57)
    ebii (61)
    havc (66)
    ktlj (57)
    fwft (72) -> ktlj, cntj, xhth
    qoyq (66)
    padx (45) -> pbga, havc, qoyq
    tknk (41) -> ugml, padx, fwft
    jptl (61)
    ugml (68) -> gyxo, ebii, jptl
    gyxo (61)
    cntj (57)
  END

  def test_part_1
    assert_equal "tknk", find_root_node_name(TEST_INPUT)
  end

  def test_part_2
    assert_equal 60, find_imbalanced_nodes_corrective_weight(TEST_INPUT)
  end

  def test_refactoring
    assert_equal "gmcrj", find_root_node_name(PUZZLE_INPUT)
    assert_equal 391, find_imbalanced_nodes_corrective_weight(PUZZLE_INPUT)
  end
end

def find_root_node_name(puzzle_input)
  discs = Disc.parse_tower(puzzle_input)
  discs.find(&:root?).name
end

def find_imbalanced_nodes_corrective_weight(puzzle_input)
  discs = Disc.parse_tower(puzzle_input)

  sibling_of_imbalance = discs.find { |disc| disc.dependents_balance? && !disc.siblings_balance? }
  siblings = sibling_of_imbalance.parent.dependents

  total_weights = siblings.map(&:total_weight)
  freq = total_weights.reduce(Hash.new(0)) { |memo, weight| memo[weight] += 1; memo }
  desired_total_weight = total_weights.max_by { |weight| freq[weight] }
  imbalanced_total_weight = (total_weights.uniq - [desired_total_weight]).first
  imbalanced_individual_weight = siblings.find { |s| s.total_weight == imbalanced_total_weight }.weight

  imbalanced_individual_weight + (desired_total_weight - imbalanced_total_weight)
end

class Disc
  def self.parse_tower(string)
    discs = string.lines.map { |line| Disc.parse_disc(line.chomp) }

    discs.each do |disc|
      disc.dependents.map! { |identifier| discs.find { |candidate| candidate.name == identifier } }
      disc.dependents.each { |dependent| dependent.parent = disc }
    end

    discs
  end

  def self.parse_disc(line)
    name, weight, _, dependents = line.split(" ", 4)
    weight = weight[1..-2].to_i
    dependents = dependents ? dependents.split(", ") : []
    new(name: name, weight: weight, dependents: dependents)
  end

  attr_accessor :name, :weight, :dependents, :parent

  def initialize(name:, weight:, dependents:)
    @name = name
    @weight = weight
    @dependents = dependents
  end

  def total_weight
    dependents.map(&:total_weight).reduce(weight, &:+)
  end

  def root?
    parent.nil?
  end

  def leaf?
    dependents.empty?
  end

  def siblings_balance?
    root? || parent.dependents_balance?
  end

  def dependents_balance?
    leaf? || dependents.map(&:total_weight).uniq.one?
  end
end

puts "🎄 " * 40
puts "Started at the bottom: #{find_root_node_name(PUZZLE_INPUT)}"
puts "New disc weight to correct imbalance: #{find_imbalanced_nodes_corrective_weight(PUZZLE_INPUT)}"
puts "🎄 " * 40