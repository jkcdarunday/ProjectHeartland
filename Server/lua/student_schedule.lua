-- ARGV[1] = session_id

-- Declare variables
local session = 'sessions:' .. ARGV[1]
local role = redis.call('hget', session, 'role')
if tonumber(role) ~= 0 then
  return {'result',9} -- invalid role / not a student
end
local student = redis.call('hget', session, 'number');

local student_schedule_key = 'students:' .. student .. ':schedule'

redis.call('expire', session, 18000)

return redis.call("HGETALL", student_schedule_key)
