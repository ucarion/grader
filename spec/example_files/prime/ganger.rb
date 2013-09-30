require 'prime'

i = STDIN.read.to_i

(0..i).each { |x| puts x if Prime.prime?(x) }
