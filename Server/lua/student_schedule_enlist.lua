-- ARGV[1] = session_id
-- ARGV[2] = subject
-- ARGV[3] = section

-- Declare variables
local session = 'sessions:' .. ARGV[1]
local subject = ARGV[2]
local section = ARGV[3]
local subject_section_key = 'subjects:' .. subject .. ':' .. section

-- Get student number from session key
local role = redis.call('hget', session, 'role')
if not role == 0 then
  return -9 -- invalid role / not a student
end
local student = redis.call('hget', session, 'number');

local student_schedule_key = 'students:' .. student .. ':schedule'

-- Check if subject is already enrolled
if redis.call('hexists',  student_schedule_key, subject) > 0 then
    return -1
end

-- Try to get a slot
local slot = redis.call('lpop', subject_section_key)
if not slot then
    return -2
end

-- Give slot to student
redis.call('hset', student_schedule_key .. ':slots', subject, section)
return 0
