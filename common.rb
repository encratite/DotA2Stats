def floatString(input)
  return sprintf('%.1f', input)
end

def percentageString(input)
  return floatString(input * 100.0) + '%'
end

def percentage(numerator, denominator)
  return percentageString(numerator.to_f / denominator)
end
