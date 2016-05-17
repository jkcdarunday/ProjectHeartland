-- ARGV[1] = session_id
-- ARGV[2] = subject
-- ARGV[3] = section

-- Declare variables
local session = 'sessions:' .. ARGV[1]
local subject = ARGV[2]
local section = ARGV[3]
local subject_section_subkey = subject .. ':' .. section
local subject_section_key = 'subjects:' .. subject_section_subkey

local days = {'mon', 'tue', 'wed', 'thu', 'fri', 'sat'}

-- Get student number from session key
local role = tonumber(redis.call('hget', session, 'role'))
if role ~= 0 then
  return -9 -- invalid role / not a student
end
local student = redis.call('hget', session, 'number');

local student_key = 'students:' .. student
local student_schedule_key = student_key .. ':schedule'

if redis.call('hexists', student_schedule_key, subject) <= 0 then
    return -1 -- subject is not enlisted
end

-- Get lecture section if it exists
local lecture_section = nil
local lecture_section_key = nil
--  if lecture subject exists, return slot
if(redis.call('exists', subject_section_key .. ':lecture') > 0) then
  lecture_section = redis.call('get', subject_section_key .. ':lecture')
  lecture_section_key = 'subjects:' .. subject .. ':' .. lecture_section
end


-- Remove and return slots
redis.call('hdel',  student_schedule_key, subject) -- remove from schedule

redis.call('rpush', subject_section_key .. ':slots', subject_section_subkey) -- add back to slots
redis.call('srem', subject_section_key .. ':students', student)
for i,day in pairs(days) do
  redis.call('sdiffstore',
    student_key .. ':schedule_set:' .. day,
    student_key .. ':schedule_set:' .. day,
    subject_section_key .. ':schedule_set:' .. day)
end

if lecture_section then
  redis.call('rpush', lecture_section_key .. ':slots', subject .. ':' .. lecture_section)
  redis.call('srem', lecture_section_key .. ':students', student)
  for i,day in pairs(days) do
    redis.call('sdiffstore',
      student_key .. ':schedule_set:' .. day,
      student_key .. ':schedule_set:' .. day,
      lecture_section_key .. ':schedule_set:' .. day)
  end
end
return 0
