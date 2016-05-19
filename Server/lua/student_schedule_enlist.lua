-- ARGV[1] = student
-- ARGV[2] = subject
-- ARGV[3] = section

-- Declare variables
local session = 'sessions:' .. ARGV[1]
local subject = ARGV[2]
local section = ARGV[3]
local subject_section_subkey = subject .. ':' .. section
local subject_section_key = 'subjects:' .. subject_section_subkey

if redis.call('exists', subject_section_key .. ':slots') <= 0 then
  return -6 -- Enlisting to a non-existant section
end

if redis.call('exists', subject_section_key .. ':impure') > 0 then
  return -4 -- Enlisting to a lecture scetion (impure)
end

local days = {'mon', 'tue', 'wed', 'thu', 'fri', 'sat'}

-- Get student number from session key
local role = tonumber(redis.call('hget', session, 'role'))
if role ~= 0 then
  return role -- invalid role / not a student
end
local student = redis.call('hget', session, 'number');

local student_key = 'students:' .. student
local student_schedule_key = student_key .. ':schedule'

redis.call('expire', session, 18000)

-- Check if subject is already enrolled
if redis.call('hexists',  student_schedule_key, subject) > 0 then
  return -1
end

if tonumber(redis.call('get', student_key .. ':total_units'))
  + tonumber(redis.call('get', subject_section_key .. ':units'))
  > tonumber(redis.call( 'get', student_key .. ':max_units')) then
    return -5 -- excessive units
end

local lecture_section = nil
local lecture_section_key = nil

--  if lecture subject exists, check for conflict
if(redis.call('exists', subject_section_key .. ':lecture') > 0) then
  lecture_section = redis.call('get', subject_section_key .. ':lecture')
  lecture_section_key = 'subjects:' .. subject .. ':' .. lecture_section
  for i,day in pairs(days) do
    if(table.getn(redis.call('sinter',
      lecture_section_key .. ':schedule_set:' .. day,
      student_key .. ':schedule_set:' .. day)) > 0) then
      return -3
    end
  end
end

-- check for conflict
for i,day in pairs(days) do
  if(table.getn(redis.call('sinter',
    subject_section_key .. ':schedule_set:' .. day,
    student_key .. ':schedule_set:' .. day)) > 0) then
    return -3
  end
end

--no conflict

-- Try to get a slot
local slot = redis.call('lpop', subject_section_key .. ':slots')
if not slot then
  return -2
end

-- check lecture if it exists
local lecture_slot = nil
if lecture_section ~= nil then
  lecture_slot = redis.call('lpop', lecture_section_key .. ':slots')
  if not lecture_slot then
    -- return lab slot if no lecture slot
    redis.call('rpush', subject_section_key .. ':slots', slot)
    return -2
  end
end

-- Give slot to student
redis.call('incrby', student_key .. ':total_units',
  tonumber(redis.call('get', subject_section_key .. ':units'))
)
redis.call('hset', student_schedule_key, subject, section)
redis.call('sadd', subject_section_key .. ':students', student)
for i,day in pairs(days) do
  redis.call('sunionstore',
    student_key .. ':schedule_set:' .. day,
    student_key .. ':schedule_set:' .. day,
    subject_section_key .. ':schedule_set:' .. day)
end
if(lecture_slot) then
  redis.call('sadd', lecture_section_key .. ':students', student)
  for i,day in pairs(days) do
    redis.call('sunionstore',
      student_key .. ':schedule_set:' .. day,
      student_key .. ':schedule_set:' .. day,
      lecture_section_key .. ':schedule_set:' .. day)
  end
end
return 0
