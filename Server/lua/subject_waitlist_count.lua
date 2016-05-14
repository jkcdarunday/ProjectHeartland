-- ARGV[1] = subject
-- ARGV[2] = section

-- Declare variables
local subject = ARGV[1]
local section = ARGV[2]
local subject_section_key = 'subjects:' .. subject .. ':' .. section


-- Return waitlisters size
return redis.call('scard', subject_section_key .. ':waitlisters')
