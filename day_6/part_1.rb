DIRECTIONS = {
  '^' => 0,
  '>' => 1,
  'v' => 2,
  '<' => 3
}

MOVEMENT = {
  0 => -> (y,x) { [y - 1, x    ] }, 
  1 => -> (y,x) { [y,     x + 1] }, 
  2 => -> (y,x) { [y + 1, x    ] }, 
  3 => -> (y,x) { [y,     x - 1] }
}


def parse_input
  map_matrix = []
  direction = 0
  File.open(ARGV[0], 'r').each_line do |line|
    row = []
    line.strip.split('').each do |char|
      if char == '.'
        row.push(0)
      elsif char == '#'
        row.push(-1)
      else
        row.push(1)
        direction = DIRECTIONS[char]
      end
    end
    map_matrix.push(row)
  end

  [map_matrix, direction]
end

def find_start_position_yx(map_matrix)
  map_matrix.each_with_index do |row, y|
    row.each_with_index do |col, x|
      return [y, x] if col == 1
    end
  end
end

def inside_map?(map_matrix, pos_yx)
  width = map_matrix[0].length
  height = map_matrix.length

  (pos_yx[0] >= 0 && pos_yx[0] < height) && 
    (pos_yx[1] >= 0 && pos_yx[1] < width)
end

def rotate_cw(direction)
  (direction + 1) % 4
end

def run_simulation!(map_matrix, direction, pos_yx)
  while inside_map?(map_matrix, pos_yx)
    puts "Direction, pos: #{direction}, #{pos_yx}"
    new_pos_yx = MOVEMENT[direction].call(pos_yx[0], pos_yx[1])
    break unless inside_map?(map_matrix, new_pos_yx)

    new_pos_content = map_matrix[new_pos_yx[0]][new_pos_yx[1]]

    if new_pos_content == -1
      direction = rotate_cw(direction)
      next
    else
      map_matrix[new_pos_yx[0]][new_pos_yx[1]] = 1
      pos_yx = new_pos_yx
    end
  end

  map_matrix
end

def uniq_positions(map_matrix)
  uniqs = 0
  map_matrix.each do |row|
    row.each do |col|
      uniqs += 1 if col == 1
    end
  end

  uniqs
end

def print_matrix(matrix)
  matrix.each do |row|
    puts "#{row}"
  end
end

def main
  map_matrix,start_direction = parse_input
  start_pos_yx = find_start_position_yx(map_matrix)

  print_matrix(map_matrix)

  run_simulation!(map_matrix, start_direction, start_pos_yx)

  print_matrix(map_matrix)

  num_uniq_positions = uniq_positions(map_matrix)
  puts "Num unique positions: #{num_uniq_positions}"
end

main

