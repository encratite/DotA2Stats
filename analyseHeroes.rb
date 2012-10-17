require 'nil/file'

output = ''
files = Nil.readDirectory('heroes')
files.each do |file|
  hero = file.name
  input = Nil.readFile(file.path)
  if input.index('unreleased content') != nil
    puts "Unreleased hero: #{hero}"
    next
  end
  pattern = /"(Strength|Agility|Intelligence) heroes"/
  match = input.match(pattern)
  if match == nil
    raise 'Unable to detect attribute'
  end
  attribute = match[1]
  roles = [
    'Carry',
    'Disabler',
    'Durable',
    'Escape',
    'Initiator',
    'Jungler',
    'Lane Support',
    'Nuker',
    'Pusher',
    'Support',
  ]
  flags = []
  roles.each do |role|
    if input.match(/Role:.+?\/> #{role}.+?Lore:/m) != nil
      roleEnum = role.gsub(/[ \-]/, '')
      flags << "HeroRole.#{roleEnum}"
    end
  end
  flagString = flags.join(', ')
  output += "\t\t\tnew Hero(\"#{hero}\", HeroAttribute.#{attribute}, #{flagString}),\n"
end
Nil.writeFile('data/heroes', output)
