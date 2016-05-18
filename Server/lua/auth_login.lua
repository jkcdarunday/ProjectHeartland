-- ARGV[1] = username
-- ARGV[2] = password
-- ARGV[3] = sess_id

-- Declare variables
local username = ARGV[1]
local password = ARGV[2]
local session_id = ARGV[3]

local user_key = 'users:' .. username

if redis.call('exists', user_key .. ':password') == 0 then
  return -2 -- user does not exist
end

local actual_password = redis.call('get', user_key .. ':password')
if(password == actual_password) then
  local number = redis.call('get', user_key .. ':number')
  if not number then
    number = ""
  end
  local role = redis.call('get', user_key .. ':role')
  redis.call('hmset', 'sessions:' .. session_id,
   'number', number, 'role', role)
  return 0
else
  return -1 -- incorrect password
end
