require 'nil/file'
require 'nil/http'

server = Nil::HTTP.new('www.dota2wiki.com')
input = server.get('/wiki/Category:Heroes')
pattern = /<li><a href="(\/wiki\/.+?)" title=".+?">(.+?)<\/a><\/li>/
input.scan(pattern) do |match|
  path = match[0]
  hero = match[1]
  if path.index('Category') != nil
    next
  end
  outputPath = "heroes/#{hero}"
  if File.exists?(outputPath)
    next
  end
  puts path
  heroData = server.get(path)
  Nil.writeFile(outputPath, heroData)
end
