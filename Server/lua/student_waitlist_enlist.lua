-- ARGV[1] = student
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

local student_key ='students:' .. student
local student_schedule_key =  student_key .. ':schedule'

-- Check if subject is already enrolled
if redis.call('hexists',  student_schedule_key, subject) > 0 then
    return -1 -- student already enrolled
end

if tonumber(redis.call('get', student_key .. ':total_units'))
  + tonumber(redis.call('get', subject_section_key .. ':units'))
  > tonumber(redis.call( 'get', student_key .. ':max_units')) then
    return -5 -- excessive units
end

-- Try to get a slot
local slot = redis.call('lpop', subject_section_key .. ':slots')
if not slot then
    if redis.call('sismember', subject_section_key .. ':waitlisters', student) <= 0 then
      -- Waitlist student
      redis.call('sadd', subject_section_key .. ':waitlisters', student)
      redis.call('hset', student_key .. ':waitlists', subject, section)
      redis.call('rpush', subject_section_key .. ':waitlist', student)
      return 0 -- successfully waitlisted
    else
      return -2 -- student is already waitlisted
    end
else
    -- Give slot to student
    redis.call('decrby', student_key .. ':total_units',
      tonumber(redis.call('get', subject_section_key .. ':units'))
    )
    redis.call('hset', student_schedule_key, subject, section)
    return 1 -- student enlisted instead of waitlisted
end
