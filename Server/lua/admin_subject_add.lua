-- script.lua subject section max_slots schedule_set lecture
local session = ARGV[1]
local subject = ARGV[2]
local section = ARGV[3]
local max_slots = tonumber(ARGV[4])
-- local schedule = ARGV[5]
local lecture = ARGV[5]

local role = redis.call('hget', session, 'role')
if not role == 9 then
  return -9 -- invalid role / not an admin
end

local subject_section_subkey = subject .. ':' .. section
local subject_section_key = 'subjects:' .. subject_section_subkey

if redis.call('exists', subject_section_key .. ':slots') > 0 then
  return -1 -- section already exists
end

if string.len(lecture) > 0 then
  local lecture_section_key = 'subjects:' .. subject .. ':' .. lecture
  if redis.call('exists', lecture_section_key .. ':slots') <= 0 then
    return -1 -- lecture section does not exist
  end
  redis.call('set', lecture_section_key .. ':impure', 1)
  redis.call('set', subject_section_key .. ':lecture', lecture)
end

if max_slots <= 0 then
  return -3 -- invaled max slots
end

local i=0
for i=1,max_slots,1 do
  redis.call('rpush', subject_section_key .. ':slots', subject_section_subkey)
end
redis.call('set', subject_section_key .. ':max_slots', max_slots)

return 0
