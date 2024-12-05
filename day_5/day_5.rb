def parse_input
  inverse_rule_hash = Hash.new { |h,k| h[k] = Set.new }
  updates = []

  before_sep = true
  File.open(ARGV[0], 'r').each_line do |line|
    line.strip!
    if line.length.zero?
      before_sep = false
      next
    end

    if before_sep
      y,x = line.split('|')
      inverse_rule_hash[y].add(x)
    else
      updates.push(line.split(','))
    end
  end

  [inverse_rule_hash, updates]
end

def update_correct?(inverse_rule_hash, update)
  checked_pages = Set.new
  update.each do |page|
    return false unless (checked_pages & inverse_rule_hash[page]).length.zero?

    checked_pages.add(page)
  end

  true
end

def fix_update(inverse_rule_hash, update)
  checked_pages = []
  update.each_with_index do |page, i|
    sub_list = checked_pages.clone
    until (Set.new(sub_list) & inverse_rule_hash[page]).length.zero?
      sub_list = sub_list[..-2]
    end
    inserted_idx = sub_list.length
    checked_pages.insert(inserted_idx, page)
  end

  checked_pages
end


def main
  inverse_rule_hash,updates = parse_input

  correct_updates = []
  incorrect_updates = []
  updates.each do |update|
    if update_correct?(inverse_rule_hash, update)
      correct_updates.push(update)
    else
      incorrect_updates.push(update)
    end
  end

  # part 1
  middle_sum = 0
  correct_updates.each do |update|
    middle_sum += update[update.length / 2].to_i
  end

  puts "Part 1 answer: #{middle_sum}"

  # part 2
  fixed_updates = []
  incorrect_updates.each do |update|
    fixed_updates.push(fix_update(inverse_rule_hash, update))
  end

  middle_sum = 0
  fixed_updates.each do |update|
    middle_sum += update[update.length / 2].to_i
  end

  puts "Part 2 answer: #{middle_sum}"
end

main
