require "minitest"
require "minitest/autorun"
require "pry"
require "awesome_print"

TEST_INPUT = File.read("lib/day_20_test_input.txt")
TEST_PART_2_INPUT = File.read("lib/day_20_test_part_2_input.txt")
PUZZLE_INPUT = File.read("lib/day_20_puzzle_input.txt")

class TheTest < Minitest::Test
  def test_part_1
    assert_equal 0, closest_in_the_long_run(TEST_INPUT)
  end

  def test_part_2
    particles = Particle.parse_puzzle(PUZZLE_INPUT)
    loop do
      particles -= find_collisions(particles)
      particles.each(&:next)
      ap particles.count
    end
  end

  def test_refactoring
    assert_equal 457, closest_in_the_long_run(PUZZLE_INPUT)
  end
end

def find_collisions(particles)
  particles.group_by { |p| p.position.to_a }.select { |_, matches| matches.size > 1 }.values.flatten
end

def closest_in_the_long_run(puzzle_input)
  particles = Particle.parse_puzzle(puzzle_input)
  min_acceleration = particles.map { |p| p.acceleration.size }.min
  particles = particles.select { |p| p.acceleration.size == min_acceleration }
  min_velocity = particles.map { |p| p.velocity.size }.min
  particles = particles.select { |p| p.velocity.size == min_velocity }
  min_position = particles.map { |p| p.position.size }.min
  particles = particles.select { |p| p.position.size == min_position }
  particles.first.id
end

def parse(line)
  line.gsub(/[^\d,-]/, "").split(",").map(&:to_i)
end

class Particle
  def self.parse_puzzle(puzzle_input)
    puzzle_input.lines.each_with_index.map { |l, id| parse_line(l, id) }
  end

  def self.parse_line(line, id)
    px, py, pz, vx, vy, vz, ax, ay, az = line.gsub(/[^\d,-]/, "").split(",").map(&:to_i)
    new(
      id: id,
      position: Coordinate.new(x: px, y: py, z: pz),
      velocity: Coordinate.new(x: vx, y: vy, z: vz),
      acceleration: Coordinate.new(x: ax, y: ay, z: az),
    )
  end

  attr_reader :id, :position, :velocity, :acceleration

  def initialize(id:, position:, velocity:, acceleration:)
    @id = id
    @position = position
    @velocity = velocity
    @acceleration = acceleration
  end

  def next
    @velocity = velocity + acceleration
    @position = position + velocity
    self
  end

  def inspect
    "id=#{id} p=#{position.inspect} v=#{velocity.inspect} a=#{acceleration.inspect}"
  end
end

class Coordinate
  attr_reader :x, :y, :z

  def initialize(x:, y:, z:)
    @x = x
    @y = y
    @z = z
  end

  def +(other)
    self.class.new(
      x: x + other.x,
      y: y + other.y,
      z: z + other.z,
    )
  end

  def to_a
    [x, y, z]
  end

  def size
    x.abs + y.abs + z.abs
  end

  def inspect
    "<#{x},#{y},#{z}>"
  end
end
