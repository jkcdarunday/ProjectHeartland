-- ARGV[1] = session_id

-- Declare variables
local session = 'sessions:' .. ARGV[1]
local role = redis.call('hget', session, 'role')
if not role == 0 then
  return -9
end
local student = redis.call('hget', session, 'number');

local student_schedule_key = 'students:' .. student .. ':schedule'

return redis.call("HGETALL", student_schedule_key)
