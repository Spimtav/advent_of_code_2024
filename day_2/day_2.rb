def parse_input
  reports = []
  File.open(ARGV[0], 'r').each_line do |line|
    reports.push(line.strip.split(' ').map(&:to_i))
  end

  reports
end

def valid?(report)
  prev_val = report[0]
  monotonic_inc = true
  monotonic_dec = true
  report[1..].each do |val|
    # rule 1
    monotonic_inc &= val > prev_val
    monotonic_dec &= val < prev_val

    return false unless monotonic_inc || monotonic_dec

    # rule 2
    diff = (val - prev_val).abs

    return false unless diff >= 1 && diff <= 3

    prev_val = val
  end

  true
end

def num_safe_reports(reports)
  num_safe = 0
  reports.each do |report|
    num_safe += 1 if valid?(report)
  end

  num_safe
end

def valid_with_dampener?(report, num_skips, depth)
  #puts "#{'  ' * depth}checking report: #{report}, num skips: #{num_skips}"
  return false if num_skips < 0
  return true if report.length <= 1

  monotonic_inc = true
  monotonic_dec = true
  (1...report.length).each do |i|
    prev_val = report[i - 1]
    val = report[i]
    
    is_inc = (val > prev_val) && monotonic_inc
    is_dec = (val < prev_val) && monotonic_dec
    diff = (val - prev_val).abs

    if diff < 1 || diff > 3 || !(is_inc || is_dec)
      report_w_prev = report[0..i-1] + report[i+1..]
      report_w_curr = report[0...i-1] + report[i..]

      keep_prev_valid = valid_with_dampener?(report_w_prev, num_skips - 1, depth + 1)
      #puts "#{'  ' * depth}keep prev branch valid: #{keep_prev_valid}"
      keep_curr_valid = valid_with_dampener?(report_w_curr, num_skips - 1, depth + 1)
      #puts "#{'  ' * depth}keep curr branch valid: #{keep_curr_valid}"

      if !(is_inc || is_dec) && i == 2
        report_wo_fst = report[i-1..]
        remove_fst = valid_with_dampener?(report_wo_fst, num_skips - 1, depth + 1)
        return keep_prev_valid || keep_curr_valid || remove_fst
      else
        return keep_prev_valid || keep_curr_valid
      end


    end

    monotonic_inc = is_inc
    monotonic_dec = is_dec
  end

  true
end

def num_safe_reports_with_dampener(reports)
  num_safe = 0
  reports.each do |report|
    puts "Report valid?: #{report}, #{valid_with_dampener?(report, 1, 0)}"
    num_safe += 1 if valid_with_dampener?(report, 1, 0)
  end

  num_safe
end


def main
  # part 1
  reports = parse_input
  num_safe = num_safe_reports(reports)
  puts "Num safe reports: #{num_safe}"

  # part 2
  reports = parse_input
  num_safe = num_safe_reports_with_dampener(reports)
  puts "Num safe reports with dampener: #{num_safe}"
end

main
