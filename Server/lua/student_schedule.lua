-- ARGV[1] = student

-- Declare variables
local student = ARGV[1]
local student_schedule_key = 'students:' .. student .. ':schedule'

return redis.call("HGETALL", student_schedule_key)
