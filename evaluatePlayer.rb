require_relative 'Evaluator'

if ![1, 2].include?(ARGV.size)
  puts 'Usage:'
  puts '<DotaBuff player ID>'
end

id = ARGV[0].to_i
accuracy = 1
if ARGV.size > 1
  accuracy = ARGV[1].to_i
end

evaluator = Evaluator.new
evaluator.evaluatePlayer(id, accuracy)
