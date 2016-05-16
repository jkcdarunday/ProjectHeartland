-- script.lua session student_number first_name middle_name last_name curriculum standing max_units
local session = ARGV[1]
local student_number = ARGV[2]
local first_name = ARGV[3]
local middle_name = ARGV[4]
local last_name = ARGV[5]
local curriculum = ARGV[6]
local standing = ARGV[7]
local max_units = tonumber(ARGV[8])

local role = redis.call('hget', session, 'role')
if not role == 9 then
  return -9 -- invalid role / not an admin
end

local student_key = 'students:' .. student_number

if redis.call('exists', student_key .. ':name') > 0 then
  return -1 -- section already exists
end

if max_units < 0 then
  return -2 -- invalid max units
end

redis.call('hmset', student_key .. ':name', 'first', first_name, 'middle', middle_name, 'last', last_name)
redis.call('set', student_key .. ':curriculum', curriculum)
redis.call('set', student_key .. ':standing', standing)
redis.call('set', student_key .. ':max_units', max_units)

return 0
