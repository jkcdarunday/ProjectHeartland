-- ARGV[1] = student
-- ARGV[2] = subject
-- ARGV[3] = section

-- Declare variables
local session = 'sessions:' .. ARGV[1]
local subject = ARGV[2]
local section = ARGV[3]
local subject_section_subkey = subject .. ':' .. section
local subject_section_key = 'subjects:' .. subject_section_subkey

-- Get student number from session key
local role = redis.call('hget', session, 'role')
if not role == 0 then
  return -9 -- invalid role / not a student
end
local student = redis.call('hget', session, 'number');

local student_schedule_key = 'students:' .. student .. ':schedule'

if not (redis.call('sismember', subject_section_key .. ':waitlisters', student) > 0) then
    return -1 -- subject is not waitlisted
end

redis.call('srem', subject_section_key .. ':waitlisters', student) -- remove from waitlisters
redis.call('lrem', subject_section_key .. ':waitlist', 0, student) -- remove from waitlist
return 0
