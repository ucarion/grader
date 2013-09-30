require 'prime'

i = STDIN.read.to_i

(0..i).each { |n| puts n if Prime.prime?(n) }
