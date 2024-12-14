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
    #puts "Direction, pos: #{direction}, #{pos_yx}"
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

def clone_matrix(matrix)
  copy = []
  matrix.each do |row|
    copy.push(row.clone)
  end

  copy
end

def initial_path_coords(marked_map, start_pos_yx)
  path_coords = []
  marked_map.each_with_index do |row, y|
    row.each_with_index do |col, x|
      next unless col == 1
      next if y == start_pos_yx[0] && x == start_pos_yx[1]

      path_coords.push([y, x])
    end
  end
  
  path_coords
end

def add_obstacle!(map_matrix, obstacle_coord)
  map_matrix[obstacle_coord[0]][obstacle_coord[1]] = -1
end

def map_cycles?(map_matrix, direction, pos_yx)
  rotation_coords_yx = Hash.new { |h,k| h[k] = {} }
  while true
    return false unless inside_map?(map_matrix, pos_yx)

    new_pos_yx = MOVEMENT[direction].call(pos_yx[0], pos_yx[1])
    return false unless inside_map?(map_matrix, new_pos_yx)


    new_pos_content = map_matrix[new_pos_yx[0]][new_pos_yx[1]]

    if new_pos_content == -1
      if rotation_coords_yx[pos_yx.to_s][direction] != 1
        rotation_coords_yx[pos_yx.to_s][direction] = 1
      else
        return true
      end

      direction = rotate_cw(direction)
      next
    else
      map_matrix[new_pos_yx[0]][new_pos_yx[1]] = 1
      pos_yx = new_pos_yx
    end
  end

  return 'help im trapped in an unreachable string factory'
end

def main
  map_matrix,start_direction = parse_input
  
  # part 1
  map_copy = clone_matrix(map_matrix)
  start_dir_copy = start_direction
  start_pos_yx = find_start_position_yx(map_copy)
  run_simulation!(map_copy, start_dir_copy, start_pos_yx)
  num_uniq_positions = uniq_positions(map_copy)
  puts "Num unique positions: #{num_uniq_positions}"

  # part 2
  path_coords_yx = initial_path_coords(map_copy, start_pos_yx)
  map_copy = clone_matrix(map_matrix)
  start_dir_copy = start_direction
  start_pos_yx = find_start_position_yx(map_copy)

  num_cycle_maps = 0
  path_coords_yx.each do |path_coord|
    map_copy = clone_matrix(map_matrix)

    add_obstacle!(map_copy, path_coord)
    loops_forever = map_cycles?(map_copy, start_dir_copy, start_pos_yx)
    num_cycle_maps += 1 if loops_forever
  end
  puts "Num cycles: #{num_cycle_maps}"
end

main

