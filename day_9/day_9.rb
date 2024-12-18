EMPTY_BLOCK_CHAR = '.'

def parse_input
  File.read(ARGV[0]).strip
end

def parse_file_map(disk_map)
  pairs = disk_map.chars.each_slice(2).map(&:join)
  pairs.map { |pair| pair.split('').map(&:to_i) }
end

def to_disk(file_map)
  disk = []
  file_blocks = {}
  empty_blocks = []
  id = 0
  i = 0

  file_map.each do |file_len, empty_len|
    file_blocks[id] = (i ... i+file_len).to_a
    file_len.times { disk.push(id) }
    i += file_len

    break if empty_len.nil?

    empty_blocks.push((i ... i+empty_len).to_a) if empty_len > 0
    empty_len.times { disk.push(EMPTY_BLOCK_CHAR) }
    i += empty_len 
    id += 1
  end

  [disk, file_blocks, empty_blocks]
end

def compact_disk!(disk, file_blocks, empty_blocks)
  curr_file_id = file_blocks.keys.max
  curr_file_pos = file_blocks[curr_file_id].pop
  curr_empty_pos = empty_blocks.shift
  while curr_file_pos > curr_empty_pos
    disk[curr_empty_pos] = curr_file_id
    disk[curr_file_pos] = EMPTY_BLOCK_CHAR

    curr_file_id -= 1 if file_blocks[curr_file_id].empty?
    curr_file_pos = file_blocks[curr_file_id].pop
    curr_empty_pos = empty_blocks.shift
  end
end

def checksum(disk)
  sum = 0
  disk.each_with_index do |id, i|
    next if id == EMPTY_BLOCK_CHAR

    sum += id * i
  end

  sum
end

def compact_disk_without_fragmentation!(disk, file_blocks, empty_blocks)
  (0..file_blocks.keys.max).reverse_each do |id|
    empty_span_idx = empty_blocks.find_index do |span| 
      span[0] < file_blocks[id][0] && span.length >= file_blocks[id].length
    end

    next if empty_span_idx.nil?

    file_blocks[id].each do |file_idx|
      empty_block_idx = empty_blocks[empty_span_idx].shift
      disk[empty_block_idx] = id
      disk[file_idx] = EMPTY_BLOCK_CHAR

      empty_blocks.delete_at(empty_span_idx) if empty_blocks[empty_span_idx].empty?
    end
  end
end


def main
  disk_map = parse_input
  file_map = parse_file_map(disk_map)
  
  # part 1
  disk,file_blocks,empty_blocks = to_disk(file_map)
  empty_blocks.flatten!
  compact_disk!(disk, file_blocks, empty_blocks)

  compacted_checksum = checksum(disk)
  puts "Checksum after compaction: #{compacted_checksum}"

  # part 2
  disk,file_blocks,empty_blocks = to_disk(file_map)
  compact_disk_without_fragmentation!(disk, file_blocks, empty_blocks)
  
  compacted_checksum = checksum(disk)
  puts "Checksum after compaction (without fragmentation): #{compacted_checksum}"
end

main
