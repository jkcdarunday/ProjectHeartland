-- ARGV[1] = sess_id

-- Declare variables
local session_id = ARGV[1]


if redis.call('del', 'sessions:' .. session_id) > 0 then
  return 0
else
  return -1 -- logout failed/not logged in
end
