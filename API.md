# Project Heartland API Specification

## /student
Contains functions that are related to the student profile and schedule.

### /student/profile (TODO)
  Returns student profile information in the structure:
```
{
	"result":0,
	"data":{
		"first_name":,
		"middle_name":,
		"last_name":,
		"student_number":,
		"curriculum":,
		"standing":,
		"total_units":,
		"available_units":
	}
}
```

### GET /student/schedule?session=[SID11]
  Returns the current schedule of the student in the structure:
```
{
	"result":0,
	"data":{
		"schedule":{"CMSC 161":"UV-1", "CMSC 124":"ST2", "CMSC 128":"AB1", ...}
  }
}
```

### PUT /student/schedule?session=[SID]&subject=[SUBJECT]&section=[SECTION]
  Enlists student to a section:
```
{
	"result":0
}
```

### DELETE /student/schedule/?session=[SID]&subject=[SUBJECT]&section=[SECTION]
  Removes student from a section:
```
{
	"result":0
}
```

### GET /student/waitlist/?session=[SID]&subject=[SUBJECT]&section=[SECTION]
  Returns the position of a student in the waitlist:
```
{
	"result":3
}
```

### PUT /student/waitlist/?session=[SID]&subject=[SUBJECT]&section=[SECTION]
  Waitlists student to a section:
```
{
	"result":0
}
```

### DELETE /student/waitlist/?session=[SID]&subject=[SUBJECT]&section=[SECTION]
  Removes a student from the waitlist of a section:
```
{
	"result":0
}
```

### /student/finalize (TODO)
  Finalizes the schedule of a student:
```
{
	"result":0
}
```


## /auth
Contains functions that manages the session.

### POST /auth/login?username=&password=
  Tries to authenticate with given credentials and returns session key
```
{
	"result":0,
	"key": "YTk0ODkwNGYyZjBmNDc5YjhmODE5NzY5NGIzMDE"  
}
```

### DELETE /auth/logout?session=?
  Terminates session of given session key
```
{
	"result":0
}
```

## /subjects
Contains functions that deal with subjects

### GET /subjects/slots?subject=[SUBJECT]&sections=[SECTION],[SECTION],[SECTION]...
  Returns the number of slots left for the given sections:
```
{
	"result":0,
	"data": {"UV": 4, "UV-1L": 4}
}
```

### PUT /subjects/create?session=[SID]&subject=[SUBJECT]&section=[SECTION]&max_slots=10&{lecture=A}
  Creates a new subject (ADMIN):
```
{
	"result":4,
}
```
