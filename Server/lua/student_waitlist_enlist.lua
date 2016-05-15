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
    return -1 -- student already enrolled
end

-- Try to get a slot
local slot = redis.call('lpop', subject_section_key .. ':slots')
if not slot then
    if not redis.call('sismember', subject_section_key .. ':waitlisters', student) > 0 then
      -- Waitlist student
      redis.call('sadd', subject_section_key .. ':waitlisters', student)
      redis.call('rpush', subject_section_key .. ':waitlist')
      return 0 -- successfully waitlisted
    else
      return -2 -- student is already waitlisted
    end
else
    -- Give slot to student
    redis.call('hset', student_schedule_key, subject, section)
    return 1 -- student enlisted instead of waitlisted
end
