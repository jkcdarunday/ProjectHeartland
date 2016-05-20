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
if tonumber(role) ~= 0 then
  return -9 -- invalid role / not a student
end
local student = redis.call('hget', session, 'number');

local student_key = 'students:' .. student
local student_schedule_key = student_key .. ':schedule'

redis.call('expire', session, 18000)

if redis.call('hexists', student_schedule_key, subject) <= 0 then
    return -1 -- subject is not enlisted
end
if redis.call('hget', student_schedule_key, subject) ~= section then
    return -2 -- invalid section
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

redis.call('decrby', student_key .. ':total_units',
  tonumber(redis.call('get', subject_section_key .. ':units'))
)

-- Pop from waitlist and enlist
local waitlist_done = 0
while waitlist_done == 0 do
  local waitlister = redis.call('lpop', subject_section_key .. ':waitlist');
  if(not waitlister) then
    break
  end
  redis.call('hdel', student_key .. ':waitlists', subject)
  redis.call('srem', subject_section_key .. ':waitlisters', waitlister)
  local waitlister_key = 'students:' .. waitlister
  local waitlister_schedule_key = waitlister_key .. ':schedule'

  -- Check if subject is already enrolled
  if redis.call('hexists',  waitlister_schedule_key, subject) > 0 then
    return 1
  end

  local lecture_section = nil
  local lecture_section_key = nil
  local conflict = false
  --  if lecture subject exists, check for conflict
  if(redis.call('exists', subject_section_key .. ':lecture') > 0) then
    lecture_section = redis.call('get', subject_section_key .. ':lecture')
    lecture_section_key = 'subjects:' .. subject .. ':' .. lecture_section
    for i,day in pairs(days) do
      if(table.getn(redis.call('sinter',
        lecture_section_key .. ':schedule_set:' .. day,
        waitlister_key .. ':schedule_set:' .. day)) > 0) then
        conflict = true
        break
      end
    end
  end

  -- check for conflict
  for i,day in pairs(days) do
    if(table.getn(redis.call('sinter',
      subject_section_key .. ':schedule_set:' .. day,
      waitlister_key .. ':schedule_set:' .. day)) > 0) then
      conflict = true
      break
    end
  end
  if(conflict) then
    waitlister = redis.call('lpop', subject_section_key .. ':waitlist');
    if(not waitlister) then
      break
    end
    redis.call('srem', subject_section_key .. ':waitlisters', waitlister)
    redis.call('hdel', student_key .. ':waitlists', subject)
  else
    --no conflict

    -- Try to get a slot
    local slot = redis.call('lpop', subject_section_key .. ':slots')
    if not slot then
      return 2
    end

    -- check lecture if it exists
    local lecture_slot = nil
    if lecture_section ~= nil then
      lecture_slot = redis.call('lpop', lecture_section_key .. ':slots')
      if not lecture_slot then
        -- return lab slot if no lecture slot
        redis.call('rpush', subject_section_key .. ':slots', slot)
        return 2
      end
    end
    -- Give slot to student
    redis.call('hset', waitlister_schedule_key, subject, section)
    redis.call('sadd', subject_section_key .. ':students', waitlister)
    for i,day in pairs(days) do
      redis.call('sunionstore',
        waitlister_key .. ':schedule_set:' .. day,
        waitlister_key .. ':schedule_set:' .. day,
        subject_section_key .. ':schedule_set:' .. day)
    end
    if(lecture_slot) then
      redis.call('sadd', lecture_section_key .. ':students', waitlister)
      for i,day in pairs(days) do
        redis.call('sunionstore',
          waitlister_key .. ':schedule_set:' .. day,
          waitlister_key .. ':schedule_set:' .. day,
          lecture_section_key .. ':schedule_set:' .. day)
      end
    end
    redis.call('incrby', waitlister_key .. ':total_units',
      tonumber(redis.call('get', subject_section_key .. ':units'))
    )
    break
  end
end

return 0
