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
if role ~= 0 then
  return -9 -- invalid role / not a student
end
local student = redis.call('hget', session, 'number');
local student_key = 'students:' .. student
local student_schedule_key =  student_key .. ':schedule'

redis.call('expire', session, 18000)

if redis.call('sismember', subject_section_key .. ':waitlisters', student) <= 0 then
    return -1 -- subject is not waitlisted
end

redis.call('srem', subject_section_key .. ':waitlisters', student) -- remove from waitlisters
redis.call('lrem', subject_section_key .. ':waitlist', 0, student) -- remove from waitlist
redis.call('hdel', student_key .. ':waitlists', subject)
redis.call('decrby', student_key .. ':total_units',
  tonumber(redis.call('get', subject_section_key .. ':units'))
)
return 0
