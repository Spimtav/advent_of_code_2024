def parse_input_part_1
  left = Hash.new { |h,k| h[k] = [] }
  right = Hash.new { |h,k| h[k] = [] }
  num_rows = 0
  File.open(ARGV[0], 'r').each_line.with_index do |line, i|
    num_rows += 1

    l,r = line.strip.split(' ')

    left[l.to_i].push(i)
    right[r.to_i].push(i)
  end
  [left, right, num_rows]
end

def match_relative(left, right, num_rows)
  left_order = left.keys.sort
  right_order = right.keys.sort
  left_order_i = 0
  right_order_i = 0

  matches = []
  puts left.length
  while matches.length < num_rows
    left_val = left_order[left_order_i]
    right_val = right_order[right_order_i]

    left_list_pos = left[left_val].shift
    right_list_pos = right[right_val].shift

    matches.push({
      left_val: left_val,
      right_val: right_val,
      left_list_pos: left_list_pos,
      right_list_pos: right_list_pos
    })

    left_order_i += 1 if left[left_val].empty?
    right_order_i += 1 if right[right_val].empty?
  end

  matches
end

def distance_sum(matches)
  sum = 0
  matches.each do |match|
    sum += (match[:left_val] - match[:right_val]).abs
  end

  sum
end

def parse_input_part_2
  left = Hash.new { |h,k| h[k] = 0 }
  right = Hash.new { |h,k| h[k] = 0 }
  File.open(ARGV[0], 'r').each_line do |line|
    l,r = line.strip.split(' ')

    left[l.to_i] += 1
    right[r.to_i] += 1
  end

  [left, right]
end

def calc_similarity(left, right)
  similarity = {}
  left.each do |k, v|
    similarity[k] = k * right[k] * v
  end

  similarity
end

def similarity_sum(similarities)
  sum = 0
  similarities.each do |_, v|
    sum += v
  end

  sum
end

def main
  # part 1 - whoops i thought this wanted index diffs not val diffs,
  #          but it's literally 4am so i'm not gonna fix it
  left,right,num_rows = parse_input_part_1
  matches = match_relative(left, right,num_rows)
  sum = distance_sum(matches)

  puts "Sum of ordered distances: #{sum}"

  # part 2
  left,right = parse_input_part_2
  similarities = calc_similarity(left, right)
  sum = similarity_sum(similarities)

  puts "Sum of similarities: #{sum}"
end

main

