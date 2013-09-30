i = STDIN.read.to_i

(2..i).each do |n|
  puts n unless (2..n - 1).any? { |x| n % x == 0 }
end
