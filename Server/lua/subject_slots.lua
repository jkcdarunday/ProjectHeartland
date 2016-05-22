-- ARGV[1] = student

-- Declare variables
local subject = ARGV[1]
local sections = ARGV[2]

local subject_key = 'subjects:' .. subject

-- local sections = redis.call('keys', subject_key .. ':*')

local section_map = {}

local index = 1
for section in string.gmatch(sections, "[^,]+") do
    section_map[(index-1)*2+1] = section
    section_map[(index-1)*2+2] = redis.call('llen', subject_key .. ':' .. section .. ':slots')
    index = index + 1
end
return section_map
