DIRECTIONS = {
  0 => -> (y,x) { [y    , x + 1] }, #right
  1 => -> (y,x) { [y    , x - 1] }, #left
  2 => -> (y,x) { [y + 1, x    ] }, #down
  3 => -> (y,x) { [y - 1, x    ] }  #up
}
TRAIL_NUM_START = 0
TRAIL_NUM_END = 9


def parse_input
  map = []
  File.open(ARGV[0], 'r').each_line do |row|
    map.push(row.strip.split('').map(&:to_i))
  end

  map
end

def print_map(map)
  map.each do |row|
    puts row.join('')
  end
end

def trailhead_coords(map)
  coords = []
  map.each_with_index do |row, y|
    row.each_with_index do |col, x|
      coords.push([y,x]) if col == TRAIL_NUM_START
    end
  end

  coords
end

def calc_next_coords(map, coord, height, width)
  new_coords = []
  DIRECTIONS.each do |_, dir|
    next_coord = dir.call(coord[0], coord[1])
    next if next_coord[0] < 0 || next_coord[0] >= height
    next if next_coord[1] < 0 || next_coord[1] >= width
    next if map[next_coord[0]][next_coord[1]] != map[coord[0]][coord[1]] + 1

    new_coords.push(next_coord)
  end

  new_coords
end

def uniq_trail_end_coords(map, start_coord, height, width)
  coords_to_check = [start_coord]
  trail_end_coords = Hash.new { |h,k| h[k] = 0 }
  until coords_to_check.empty?
    coord = coords_to_check.shift

    trail_end_coords[coord.to_s] += 1 if map[coord[0]][coord[1]] == TRAIL_NUM_END

    next_coords = calc_next_coords(map, coord, height, width)
    coords_to_check.concat(next_coords)
  end

  trail_end_coords
end

def calc_trailhead_sums(map, start_coords, height, width)
  score_sum = 0
  rating_sum = 0
  start_coords.each do |start_coord|
    uniq_coords = uniq_trail_end_coords(map, start_coord, height, width)
    
    score_sum += uniq_coords.keys.length
    rating_sum += uniq_coords.values.reduce(0, :+)
  end

  [score_sum, rating_sum]
end


def main
  map = parse_input
  height = map.length
  width = map[0].length
  start_coords = trailhead_coords(map)
  print_map(map)

  score_sum,rating_sum = calc_trailhead_sums(map, start_coords, height, width)
  # part 1
  puts "Trailhead score sum: #{score_sum}"

  # part 2
  puts "Trailhead rating sum: #{rating_sum}"
end

main
