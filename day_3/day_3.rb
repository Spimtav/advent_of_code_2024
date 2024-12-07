def parse_input
  input = ''
  File.open(ARGV[0], 'r').each_line do |line|
    input += line.strip
  end

  input
end

def find_matches(input)
  input.scan(/mul\((\d+),(\d+)\)/)
end

def product_sum(matches)
  products = matches.map do |match|
    match[0].to_i * match[1].to_i
  end

  products.reduce(:+)
end

def find_muls_and_logic(input)
  input.scan(/mul\((\d+),(\d+)\)|(do\(\))|(don\'t\(\))/)
end

def remove_disabled_matches(matches)
  enabled_matches = []
  enabled = true
  matches.each do |match|
    if match[2] != nil
      enabled = true
      next
    elsif match[3] != nil
      enabled = false
      next
    end

    enabled_matches.push(match) if enabled
  end

  enabled_matches
end


def main
  # part 1
  input = parse_input
  matches = find_matches(input)
  sum = product_sum(matches)

  puts "Sum of products: #{sum}"

  # part 2
  matches = find_muls_and_logic(input)
  enabled_matches = remove_disabled_matches(matches)
  sum = product_sum(enabled_matches)

  puts "Sum of enabled products: #{sum}"
end

main
