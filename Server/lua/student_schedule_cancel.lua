-- ARGV[1] = student
-- ARGV[2] = subject
-- ARGV[3] = section

-- Declare variables
local student = ARGV[1]
local subject = ARGV[2]
local section = ARGV[3]
local student_schedule_key = 'students:' .. student .. ':schedule'
local subject_section_subkey = subject .. ':' .. section
local subject_section_key = 'subjects:' .. subject_section_subkey

if not (redis.call('hexists', student_schedule_key, subject) > 0) then
    return -1 -- subject is not enlisted
end

redis.call('hdel',  student_schedule_key, subject) -- remove from schedule
redis.call('rpush', subject_section_key, subject_section_subkey) -- add back to slots
return 0
