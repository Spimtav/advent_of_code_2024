EMPTY_MAP_CHAR = '.'

def parse_input
  map = []
  File.open(ARGV[0], 'r').each_line do |line|
    map.push(line.strip.split(''))
  end

  map
end

def print_map(map)
  map.each do |row|
    puts row.join('')
  end
end

def find_antenna_coords(map)
  antenna_coords = Hash.new { |h,k| h[k] = [] }
  map.each_with_index do |row, y|
    row.each_with_index do |col, x|
      next if col == EMPTY_MAP_CHAR

      antenna_coords[col].push([y, x])
    end
  end

  antenna_coords
end

def calc_slope(coord_1, coord_2)
  change_y = coord_2[0] - coord_1[0]
  change_x = coord_2[1] - coord_1[1]

  gcd = change_y.gcd(change_x)
  [change_y / gcd, change_x / gcd]
end

def coord_in_map?(coord, height, width)
  coord[0] >= 0 && coord[0] < height && coord[1] >= 0 && coord[1] < width
end

def coords_on_slope(ant_coord_1, ant_coord_2, slope, height, width)
  slope_coords = []
  [1, -1].each do |dir|
    coord = ant_coord_1.clone
    while coord_in_map?(coord, height, width)
      slope_coords.push(coord)
      new_y = coord[0] + (dir * slope[0])
      new_x = coord[1] + (dir * slope[1])
      coord = [new_y, new_x]
    end
  end
  
  slope_coords
end

def is_twice_dist?(coord, ant_coord_1, ant_coord_2)
  diff_1 = [ant_coord_1[0] - coord[0], ant_coord_1[1] - coord[1]]
  diff_2 = [ant_coord_2[0] - coord[0], ant_coord_2[1] - coord[1]]

  first_coord_twice_dist  = (2 * diff_1[0] ==     diff_2[0]) && (2 * diff_1[1] ==     diff_2[1])
  second_coord_twice_dist = (    diff_1[0] == 2 * diff_2[0]) && (    diff_1[1] == 2 * diff_2[1])

  first_coord_twice_dist || second_coord_twice_dist
end


def main
  map = parse_input
  height = map.length
  width = map[0].length
  antenna_coords = find_antenna_coords(map)

  print_map(map)
  #pp antenna_coords

  antinode_coords_part_1 = Hash.new { |h,k| h[k] = []  }
  antinode_coords_part_2 = Hash.new { |h,k| h[k] = []  }

  antenna_coords.each do |freq, coords|
    coords.each_with_index do |ant_coord_1, i|
      coords[i+1..].each do |ant_coord_2| 
        slope = calc_slope(ant_coord_1, ant_coord_2)
        slope_coords = coords_on_slope(ant_coord_1, ant_coord_2, slope, height, width)

        slope_coords.each do |slope_coord|
          antinode_coords_part_2[slope_coord].push(freq)
          next unless is_twice_dist?(slope_coord, ant_coord_1, ant_coord_2)

          antinode_coords_part_1[slope_coord].push(freq)
        end
      end
    end
  end

  puts "Num unique antinodes (2x dist): #{antinode_coords_part_1.keys.length}"
  puts "Num unique antinodes (with harmonics): #{antinode_coords_part_2.keys.length}"
end

main
