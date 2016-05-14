-- ARGV[1] = student

-- Declare variables
local subject = ARGV[1]
local subject_key = 'subjects:' .. subject

local sections = redis.call('keys', subject_key .. ':*')

local section_map = {}

for index, value in pairs(sections) do
    section_map[(index-1)*2+1] = value
    section_map[(index-1)*2+2] = redis.call('llen', value);
end
return section_map  
