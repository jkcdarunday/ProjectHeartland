-- ARGV[1] = student
-- ARGV[2] = subject
-- ARGV[3] = section

-- Declare variables
local student = ARGV[1]
local subject = ARGV[2]
local section = ARGV[3]
local student_schedule_key = 'students:' .. student .. ':schedule'
local subject_section_key = 'subjects:' .. subject .. ':' .. section

local waitlist = redis.call('lrange', subject_section_key .. ':waitlist', 0, -1)
for i=1,#waitlist do
    if waitlist[i] == student then
        return i - 1
    end
end 
return -1
