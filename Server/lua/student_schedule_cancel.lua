-- ARGV[1] = session_id
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
  return -9
end
local student = redis.call('hget', session, 'number');

local student_schedule_key = 'students:' .. student .. ':schedule'

if not (redis.call('hexists', student_schedule_key, subject) > 0) then
    return -1 -- subject is not enlisted
end

redis.call('hdel',  student_schedule_key, subject) -- remove from schedule
redis.call('rpush', subject_section_key .. ':slots', subject_section_subkey) -- add back to slots
return 0
