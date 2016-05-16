# Project Heartland API Specification

## /student
Contains functions that are related to the student profile and schedule.

### /student/profile (TODO)
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

### GET /student/schedule?session=?
  Returns the current schedule of the student in the structure:
```
{
	result:0,
  data:{
  	schedule:{"CMSC 161":"UV-1", "CMSC 124":"ST2", "CMSC 128":"AB1", ...}
  }
}
```

### PUT /student/schedule/[SUBJECT]/[SECTION]?session=?
  Enlists student to a section:
```
{
	result:0
}
```

### DELETE /student/schedule/[SUBJECT]/[SECTION]?session=?
  Removes student from a section:
```
{
	result:0
}
```

### GET /student/waitlist/[SUBJECT]/[SECTION]?session=?
  Returns the position of a student in the waitlist:
```
{
	result:3
}
```

### PUT /student/waitlist/[SUBJECT]/[SECTION]?session=?
  Waitlists student to a section:
```
{
	result:0
}
```

### DELETE /student/waitlist/[SUBJECT]/[SECTION]?session=?
  Removes a student from the waitlist of a section:
```
{
	result:0
}
```

### /student/finalize (TODO)
  Finalizes the schedule of a student:
```
{
	result:0
}
```


## /auth
Contains functions that manages the session.

### POST /auth/login?username=&password=
  Tries to authenticate with given credentials and returns session key
```
{
	result:0,
  key: "YTk0ODkwNGYyZjBmNDc5YjhmODE5NzY5NGIzMDE"  
}
```

### DELETE /auth/logout?session=?
  Terminates session of given session key
```
{
	result:0
}
```

## /subjects
Contains functions that deal with subjects

### GET /subjects/[SUBJECT]/[SECTION] (TODO)
  Returns the number of slots left for a given section:
```
{
	result:4,
}
```
