-- ARGV[1] = session_id

-- Declare variables
local session = 'sessions:' .. ARGV[1]
local role = redis.call('hget', session, 'role')
if role ~= 0 then
  return {"result", -9} -- invalid role / not a student
end
local student = redis.call('hget', session, 'number');
local student_key = 'students:' .. student

redis.call('expire', session, 18000)

local profile_map = {}

profile_map[1] = 'first_name'
profile_map[2] = tostring(redis.call('hget', student_key.. ':name', 'first') or '')
profile_map[3] = 'middle_name'
profile_map[4] = tostring(redis.call('hget', student_key.. ':name', 'middle') or '')
profile_map[5] = 'last_name'
profile_map[6] = tostring(redis.call('hget', student_key.. ':name', 'last') or '')
profile_map[7] = 'student_number'
profile_map[8] = tostring(student or '')
profile_map[9] = 'curriculum'
profile_map[10] = tostring(redis.call('get', student_key.. ':curriculum') or '')
profile_map[11] = 'standing'
profile_map[12] = tostring(redis.call('get', student_key.. ':standing') or '')
profile_map[13] = 'total_units'
profile_map[14] = tostring(redis.call('get', student_key.. ':total_units') or '')
profile_map[15] = 'max_units'
profile_map[16] = tostring(redis.call('get', student_key.. ':max_units') or '')

return profile_map
