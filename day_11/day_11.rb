RULES = [
  {
    rule:   -> (val) { val == 0 },
    change: -> (val) { [1] }
  },
  {
    rule:   -> (val) { val.to_s.length % 2 == 0 },
    change: -> (val) { pwr = val.to_s.length / 2; [val / (10**pwr), val % (10**pwr)] }
  },
  {
    rule:   -> (val) { true },
    change: -> (val) { [val * 2024] }
  }
]
DFS_MEMO = {}

def parse_input
  File.read(ARGV[0]).strip.split(' ').map(&:to_i)
end

def blink_bfs(stones)
  new_stones = []
  stones.each do |stone|
    rule_idx = RULES.find_index { |rule| rule[:rule].call(stone) }
    new_stones.concat(RULES[rule_idx][:change].call(stone))
  end

  new_stones
end

def blink_bfs_times(stones, num)
  (0...num).each do |i|
    stones = blink_bfs(stones)
  end

  stones
end

def blink_dfs_times_len(stone, num)
  return 1 if num <= 0

  sum = 0
  rule_idx = RULES.find_index { |rule| rule[:rule].call(stone) }
  RULES[rule_idx][:change].call(stone).each do |new_stone|
    sum += blink_dfs_times_len(new_stone, num - 1)
  end

  sum
end

def blink_bfs_with_memo(stones, memo)
  new_stones = []
  stones.each do |stone|
    if memo[stone].nil?
      rule_idx = RULES.find_index { |rule| rule[:rule].call(stone) }
      changed_stones = RULES[rule_idx][:change].call(stone)

      memo[stone] = changed_stones
    else
      changed_stones = memo[stone]
    end

    new_stones.concat(changed_stones)
  end

  new_stones
end

def blink_bfs_times_with_memo(stones, num)
  memo = {}
  (0...num).each do |i|
    stones = blink_bfs_with_memo(stones, memo)
  end

  stones
end

def blink_dfs_times_with_memo_len(stone, num)
  memo_key = "#{stone},#{num}"

  return DFS_MEMO[memo_key] unless DFS_MEMO[memo_key].nil?
  return 1 if num <= 0

  rule_idx = RULES.find_index { |rule| rule[:rule].call(stone) }
  length = 0
  RULES[rule_idx][:change].call(stone).each do |new_stone|
    length += blink_dfs_times_with_memo_len(new_stone, num - 1)
  end

  DFS_MEMO[memo_key] = length

  length
end


def main
  stones = parse_input
  num_blinks = [25, 75]
  
  num_blinks.each do |num|
    start_time = Time.now
    length = 0
    stones.each do |stone|
      length += blink_dfs_times_with_memo_len(stone, num)
    end
    end_time = Time.now
    puts "Num stones after #{num} blinks: #{length} (#{end_time - start_time}s) (dfs w/ memo)"
  end
end

main
