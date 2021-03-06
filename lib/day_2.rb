require "minitest"
require "minitest/autorun"

TEST_MINMAX_SHEET = <<~ROWS
5 1 9 5
7 5 3
2 4 6 8
ROWS

TEST_DIVISION_SHEET = <<~ROWS
5 9 2 8
9 4 7 3
3 8 6 5
ROWS

class TheTest < Minitest::Test
  def test_row_minmax_checksum
    skip "Changing the argument from a string to the array of integers"
    assert_equal 8, row_minmax_checksum("5 1 9 5")
    assert_equal 4, row_minmax_checksum("7 5 3")
    assert_equal 6, row_minmax_checksum("2 4 6 8")
  end

  def test_sheet_minmax_checksum
    assert_equal 18, sheet_minmax_checksum(TEST_MINMAX_SHEET)
  end

  def test_row_division_checksum
    skip "Changing the argument from a string to the array of integers"
    assert_equal 4, row_division_checksum("5 9 2 8")
    assert_equal 3, row_division_checksum("9 4 7 3")
    assert_equal 2, row_division_checksum("3 8 6 5")
  end

  def test_sheet_division_checksum
    assert_equal 9, sheet_division_checksum(TEST_DIVISION_SHEET)
  end

  def test_refactoring_correct_answers
    assert_equal 39126, sheet_minmax_checksum(SHEET)
    assert_equal 258, sheet_division_checksum(SHEET)
  end
end

def sheet_checksum(sheet)
  coerced = sheet.lines.map { |row| row.split.map(&:to_i) }
  coerced.reduce(0) { |memo, row| memo + yield(row) }
end

def sheet_minmax_checksum(sheet)
  sheet_checksum(sheet) { |row| row.max - row.min }
end

def sheet_division_checksum(sheet)
  sheet_checksum(sheet) { |row| find_whole_quotient_in_sorted_list(row.sort.reverse) }
end

def find_whole_quotient_in_sorted_list(list)
  head = list[0]
  tail = list[1..-1]

  if whole_divisor = tail.find { |divisor| (head % divisor).zero? }
    head / whole_divisor
  else
    find_whole_quotient_in_sorted_list(tail)
  end
end

SHEET = <<~ROWS
179	2358	5197	867	163	4418	3135	5049	187	166	4682	5080	5541	172	4294	1397
2637	136	3222	591	2593	1982	4506	195	4396	3741	2373	157	4533	3864	4159	142
1049	1163	1128	193	1008	142	169	168	165	310	1054	104	1100	761	406	173
200	53	222	227	218	51	188	45	98	194	189	42	50	105	46	176
299	2521	216	2080	2068	2681	2376	220	1339	244	605	1598	2161	822	387	268
1043	1409	637	1560	970	69	832	87	78	1391	1558	75	1643	655	1398	1193
90	649	858	2496	1555	2618	2302	119	2675	131	1816	2356	2480	603	65	128
2461	5099	168	4468	5371	2076	223	1178	194	5639	890	5575	1258	5591	6125	226
204	205	2797	2452	2568	2777	1542	1586	241	836	3202	2495	197	2960	240	2880
560	96	336	627	546	241	191	94	368	528	298	78	76	123	240	563
818	973	1422	244	1263	200	1220	208	1143	627	609	274	130	961	685	1318
1680	1174	1803	169	450	134	3799	161	2101	3675	133	4117	3574	4328	3630	4186
1870	3494	837	115	1864	3626	24	116	2548	1225	3545	676	128	1869	3161	109
890	53	778	68	65	784	261	682	563	781	360	382	790	313	785	71
125	454	110	103	615	141	562	199	340	80	500	473	221	573	108	536
1311	64	77	1328	1344	1248	1522	51	978	1535	1142	390	81	409	68	352
ROWS

result = sheet_minmax_checksum(SHEET)
division_result = sheet_division_checksum(SHEET)

puts "🎄 " * 40
puts "Sheet minmax checksum: #{result}"
puts "Sheet division checksum: #{division_result}"
puts "🎄 " * 40