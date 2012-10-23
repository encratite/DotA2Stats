require_relative 'Evaluator'

if ARGV.size < 1
  puts 'Usage:'
  puts '<DotaBuff match IDs>'
end

evaluator = Evaluator.new
evaluator.evaluateMatchPercentileRanges(ARGV)
