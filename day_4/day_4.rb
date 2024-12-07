WORD_ORDER = {
  0 => 'X',
  1 => 'M',
  2 => 'A',
  3 => 'S'
}

DIRECTION_CHANGES = {
  0 => -> (o,y,x) { [o + 1, y    , x + 1] }, # right
  1 => -> (o,y,x) { [o + 1, y    , x - 1] }, # left
  2 => -> (o,y,x) { [o + 1, y - 1, x    ] }, # up
  3 => -> (o,y,x) { [o + 1, y + 1, x    ] }, # down
  4 => -> (o,y,x) { [o + 1, y - 1, x - 1] }, # diag UL
  5 => -> (o,y,x) { [o + 1, y - 1, x + 1] }, # diag UR
  6 => -> (o,y,x) { [o + 1, y + 1, x + 1] }, # diag DR
  7 => -> (o,y,x) { [o + 1, y + 1, x - 1] }  # diag DL
}

ROOT_DIRECTION = '*'


def parse_input
  puzzle = []
  File.open(ARGV[0], 'r').each_line do |line|
    puzzle.push(line.strip.split(''))
  end

  puzzle
end

def print_puzzle(puzzle)
  puzzle.each do |line|
    puts line.join('')
  end
end

def find_xmas_root_coords(puzzle)
  root_coords = []
  puzzle.each_with_index do |row, y|
    row.each_with_index do |col, x|
      root_coords.push([0, y, x]) if col == WORD_ORDER[0]
    end
  end

  root_coords
end

def count_all_xmas_words(puzzle, root_coords)
  height = puzzle.length
  width = puzzle[0].length
  num_words = 0
  root_coords.each do |letter, y, x|
    num_words += num_xmas_words_in_puzzle(puzzle, height, width, ROOT_DIRECTION, letter, y, x)
  end

  num_words
end

def num_xmas_words_in_puzzle(puzzle, height, width, dir, letter, y, x)
  # success case
  return 1 if letter > WORD_ORDER.keys.max

  # negative base cases
  return 0 if y < 0 || y >= height
  return 0 if x < 0 || x >= width
  return 0 if puzzle[y][x] != WORD_ORDER[letter]

  # recursion
  dirs = []
  if dir == ROOT_DIRECTION
    dirs = DIRECTION_CHANGES.to_a
  else
    dirs.push([dir, DIRECTION_CHANGES[dir]])
  end

  num_words = 0
  dirs.each do |new_dir, change|
    new_letter,new_y,new_x = change.call(letter, y, x)
    num_words += num_xmas_words_in_puzzle(puzzle, height, width, new_dir, new_letter, new_y, new_x)
  end

  num_words
end

def find_x_root_coords(puzzle)
  root_coords = []
  puzzle.each_with_index do |row, y|
    row.each_with_index do |col, x|
      root_coords.push([y, x]) if col == WORD_ORDER[2]
    end
  end

  root_coords
end

def num_xs_in_puzzle(puzzle, x_root_coords)
  height = puzzle.length
  width = puzzle[0].length

  num_xs = 0
  x_root_coords.each do |y, x|
    corner_coords = {}

    (4..7).each do |i|
      corner_coords[i - 4] = DIRECTION_CHANGES[i].call(0, y, x)[1..]
    end

    all_coords_in_bounds = corner_coords.values.all? do |y,x|
      y >= 0 && y < height && x >= 0 && x < width
    end
    next unless all_coords_in_bounds

    corner_letters = {}
    corner_coords.each do |i, coord|
      corner_letters[i] = puzzle[coord[0]][coord[1]]
    end
    letter_str = corner_letters.values.join('')
    next unless letter_str.count(WORD_ORDER[1]) == 2 && letter_str.count(WORD_ORDER[3]) == 2

    adjacent_ms = false
    (0..3).each do |i|
      adjacent_ms ||= corner_letters[i] == WORD_ORDER[1] && corner_letters[(i + 1) % 4] == WORD_ORDER[1]
    end

    num_xs += 1 if adjacent_ms
  end

  num_xs
end


def main
  puzzle = parse_input

  # part 1
  xmas_root_coords = find_xmas_root_coords(puzzle)
  num_xmas_words = count_all_xmas_words(puzzle, xmas_root_coords)

  puts "Num XMASes in puzzle: #{num_xmas_words}"

  # part 2
  x_root_coords = find_x_root_coords(puzzle)
  num_x_words = num_xs_in_puzzle(puzzle, x_root_coords)

  puts "num X-MASes in puzzle: #{num_x_words}"
end

main
