-- ARGV[1] = username
-- ARGV[2] = password
-- ARGV[3] = sess_id

-- Declare variables
local username = ARGV[2]
local password = ARGV[3]
local session = 'sessions:' .. ARGV[1]
local role = redis.call('hget', session, 'role')
if role ~= 9 then
  return -9 -- invalid role / not an admin
end

redis.call('expire', session, 18000)

if( redis.call('exists', 'admin') > 0) then
  return -8
end

local user_key = 'users:' .. username

if redis.call('exists', user_key .. ':number') > 0 then
  return -1 -- user already exists
end

redis.call('set', user_key .. ':password', password)
redis.call('set', user_key .. ':role', 9)

return 0
