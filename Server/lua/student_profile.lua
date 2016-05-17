-- ARGV[1] = session_id

-- Declare variables
local session = 'sessions:' .. ARGV[1]
local role = redis.call('hget', session, 'role')
if not role == 0 then
  return {"result", -9} -- invalid role / not a student
end
local student = redis.call('hget', session, 'number');
local student_key = 'students:' .. student

local profile_map = {}

section_map[0] = 'first_name'
section_map[1] = redis.call('hget', student_key.. ':name', 'first')
section_map[2] = 'middle_name'
section_map[3] = redis.call('hget', student_key.. ':name', 'middle')
section_map[4] = 'last_name'
section_map[5] = redis.call('hget', student_key.. ':name', 'last')
section_map[6] = 'student_number'
section_map[7] = student
section_map[8] = 'curriculum'
section_map[9] = redis.call('get', student_key.. ':curriculum')
section_map[10] = 'standing'
section_map[11] = redis.call('get', student_key.. ':standing')
section_map[12] = 'total_units'
section_map[13] = redis.call('get', student_key.. ':total_units')
section_map[14] = 'max_units'
section_map[15] = redis.call('get', student_key.. ':max_units')

return section_map
