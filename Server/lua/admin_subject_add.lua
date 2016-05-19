-- script.lua subject section max_slots schedule_set lecture
local session = ARGV[1]
local subject = ARGV[2]
local section = ARGV[3]
local max_slots = tonumber(ARGV[4])
local schedule = ARGV[5]
local units = tonumber(ARGV[6])
local lecture = ARGV[7]
local pure = tonumber(ARGV[8])

local role = redis.call('hget', session, 'role')
if role ~= 9 then
  return -9 -- invalid role / not an admin
end

local subject_section_subkey = subject .. ':' .. section
local subject_section_key = 'subjects:' .. subject_section_subkey

redis.call('expire', session, 18000)

if redis.call('exists', subject_section_key .. ':slots') > 0 then
  return -1 -- section already exists
end

-- set impurity, units, and lecture
if pure == 0 then
  redis.call('set', subject_section_key .. ':impure', 1)
end
if string.len(lecture) > 0 then
  local lecture_section_key = 'subjects:' .. subject .. ':' .. lecture
  if redis.call('exists', lecture_section_key .. ':slots') <= 0 then
    return -1 -- lecture section does not exist
  end
  redis.call('set', lecture_section_key .. ':impure', 1)
  redis.call('set', subject_section_key .. ':lecture', lecture)
end

if max_slots < 0 then
  return -3 -- invalid max slots
end

if units >= 0 then
  redis.call('set', subject_section_key .. ':units', units)
else
  redis.call('set', subject_section_key .. ':units', 0)
end

-- write slots
local i=0
for i=1,max_slots,1 do
  redis.call('rpush', subject_section_key .. ':slots', subject_section_subkey)
end
redis.call('set', subject_section_key .. ':max_slots', max_slots)

local days = {'mon', 'tue', 'wed', 'thu', 'fri', 'sat'}

-- write schedule
local scheds = {}
scheds['mon'],
 scheds['tue'],
  scheds['wed'],
   scheds['thu'],
    scheds['fri'],
     scheds['sat']
     = string.match(schedule, "([^|]*)|([^|]*)|([^|]*)|([^|]*)|([^|]*)|([^|]*)")
for i,day in pairs(days) do
  for code in string.gmatch(scheds[day], "[^,]+") do
    redis.call('sadd', subject_section_key .. ':schedule_set:' .. day, tonumber(code))
  end
end

return 0
