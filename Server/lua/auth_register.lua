-- ARGV[1] = username
-- ARGV[2] = password
-- ARGV[3] = sess_id

-- Declare variables
local username = ARGV[1]
local password = ARGV[2]
local role = tonumber(ARGV[3])
local number = ARGV[4]

local user_key = 'users:' .. username

if role == 9 and redis.call('exists', 'admin') > 0 then
  return -8
end

if redis.call('exists', user_key .. ':number') > 0 then
  return -1 -- user already exists
end

redis.call('set', user_key .. ':password', password)
redis.call('set', user_key .. ':role', role)
if number then
  redis.call('set', user_key .. ':number', number)
end
if role == 9 then
  redis.call('set', 'admin', username)
end

return 0
