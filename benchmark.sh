#!/bin/sh

###
# How to use the benchmark:
# create a user using the HeartlandTester
# supply the $dummy_user and $dummy_pass variables with respective data
# login with the dummy account using the HeartlandTester then store the session key to
# the variable $session
# run this shell script : sh benchmark.sh or chmod +x benchmark.sh && ./benchmark
###

$dummy_user=''
$dummy_pass=''
$session=''

redis-cli --raw keys "sessions:*" | xargs redis-cli del
ab -m POST -n 100000 -c 2000 "http://127.0.0.1:3000/auth/login?username=$dummy_user&password=$dummy_user" #login simulation
ab -m GET -n 100000 -c 2000 "http://127.0.0.1:3000/student/schedule?session=$session" #get schedule simulation
#database benchmarking
redis-benchmark -r 100000 -n 100000 eval "$(cat lua/student_schedule_enlist.lua)" 0 "" "CMSC 2" "UV-1L"
redis-benchmark -r 100000 -n 100000 eval "$(cat lua/student_schedule_cancel.lua)" 0 "" "CMSC 2" "UV-1L"
redis-benchmark -r 100000 -n 100000 eval "$(cat lua/student_waitlist_enlist.lua)" 0 "" "CMSC 2" "UV-1L"
redis-benchmark -r 100000 -n 100000 eval "$(cat lua/student_waitlist_cancel.lua)" 0 "" "CMSC 2" "UV-1L"
