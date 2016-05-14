-- ARGV[1] = student
-- ARGV[2] = subject
-- ARGV[3] = section

-- Declare variables
local student = ARGV[1]
local subject = ARGV[2]
local section = ARGV[3]
local student_schedule_key = 'students:' .. student .. ':schedule'
local subject_section_key = 'subjects:' .. subject .. ':' .. section

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
redis.call('hset', student_schedule_key, subject, section)
return 0
