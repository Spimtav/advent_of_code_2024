OPERATOR_ADD = '+'
OPERATOR_MUL = '*'
OPERATOR_CONCAT = '|'

OPERATORS_PART_1 = [
  OPERATOR_ADD,
  OPERATOR_MUL
]
OPERATORS_PART_2 = [
  OPERATOR_ADD,
  OPERATOR_MUL,
  OPERATOR_CONCAT
]


def parse_input
  equations = []
  File.open(ARGV[0], 'r').each_line do |line|
    sides = line.strip.split(':')
    operands = sides[1].strip.split(' ')
    equations.push([sides[0], operands])
  end

  equations
end

def max_num_operands(equations)
  max_length = 0
  equations.each do |result, operands|
    max_length = [max_length, operands.length].max
  end

  max_length
end

def operator_permutations(max_length, operators)
  all_perms = Hash.new { |h,k| h[k] = [''] }
  
  (1...max_length).each do |len|
    prev_perms = all_perms[len - 1]
   
    new_perms = []
    operators.each do |operator|
      perms = prev_perms.clone
      perms = perms.map { |perm| "#{perm}#{operator}" }
      new_perms.concat(perms)
    end

    all_perms[len] = new_perms
  end

  all_perms
end

def valid?(result, operands, operator_perms)
  perms = operator_perms[operands.length - 1]
  perms.any? do |perm|
    calc = operands[0]
    (0..perm.length).each do |i|
      if perm[i] == OPERATOR_CONCAT
        calc = "#{calc}#{operands[i + 1]}"
      else
        calc = eval("#{calc}#{perm[i]}#{operands[i + 1]}")
      end
    end
    
    result.to_i == calc
  end
end

def valid_equation_sum(equations, operator_perms)
  valid_equations = []
  equations.each do |equation|
    valid_equations.push(equation) if valid?(equation[0], equation[1], operator_perms)
  end
  
  valid_equations.reduce(0) { |acc, equation| acc + equation[0].to_i }
end


def main
  equations = parse_input
  max_length = max_num_operands(equations)
  
  # part 1
  operator_perms = operator_permutations(max_length, OPERATORS_PART_1)
  valid_sum = valid_equation_sum(equations, operator_perms)
  puts "Total calibration result: #{valid_sum}"

  # part 2
  operator_perms = operator_permutations(max_length, OPERATORS_PART_2) 
  valid_sum = valid_equation_sum(equations, operator_perms)
  puts "Total calibration_result with concats: #{valid_sum}"
end

main
