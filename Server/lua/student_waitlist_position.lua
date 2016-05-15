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
  return -9
end
local student = redis.call('hget', session, 'number');

local student_schedule_key = 'students:' .. student .. ':schedule'
local waitlist = redis.call('lrange', subject_section_key .. ':waitlist', 0, -1)
for i=1,#waitlist do
    if waitlist[i] == student then
        return i - 1
    end
end
return -1
