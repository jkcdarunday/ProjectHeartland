# Project Heartland API Specification

## /student
Contains functions that are related to the student profile and schedule.

* ### /student/profile
  Returns student profile information in the structure:
```
{
	result:0,
    data:{
    	first_name:,
        middle_name:,
        last_name:,
        student_number:,
        curriculum:,
        standing:,
        total_units:,
        available_units:
	}
}
```

* ### /student/schedule
  Returns the current schedule of the student in the structure:
```
{
	result:0,
    data:{
    	schedule:["CMSC 161|UV-1", "CMSC 124|ST2", "CMSC 128|AB1", ...]
	}
}
```

* ### /student/enlist
  Enlists student to a section:
```
{
	result:0
}
```

* ### /student/waitlist
  Waitlists student to a section:
```
{
	result:0
}
```

* ### /student/cancel
  Removes student from a section:
```
{
	result:0
}
```

* ### /student/finalize
  Finalizes the schedule of a student:
```
{
	result:0
}
```


## /auth
Contains functions that manages the session.

* ### /auth/login
  Tries to authenticate with given credentials and returns session key
```
{
	result:0,
    key: "YTk0ODkwNGYyZjBmNDc5YjhmODE5NzY5NGIzMDE"
}
```

* ### /auth/logout
  Terminates session of given session key
```
{
	result:0
}
```

## /subjects
Contains functions that returns data from the list of sections

* ### /subjects/[subject]
  Returns list of sections of a subject
```
{
	result:0,
    data:{
    	"AB1": 10,
        "AB2": 5,
    }
}
```
