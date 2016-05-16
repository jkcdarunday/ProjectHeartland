-- ARGV[1] = username
-- ARGV[2] = password
-- ARGV[3] = sess_id

-- Declare variables
local username = ARGV[1]
local password = ARGV[2]
local role = ARGV[3]
local number = ARGV[4]

local user_key = 'user:' .. username

if redis.call('exists', user_key .. ':number') > 0 then
  return -1 -- user already exists
end

redis.call('set', user_key .. ':password', password)
redis.call('set', user_key .. ':role', role)
redis.call('set', user_key .. ':number', number)

return 0
