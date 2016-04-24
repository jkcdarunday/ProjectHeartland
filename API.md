
# Project Heartland API Specification

## /student
Contains functions that are related to the student profile and schedule.

* ### /student/profile
  Returns student profile information

* ### /student/schedule
  Returns the current schedule of the student

* ### /student/enlist
  Enlists student to a section

* ### /student/waitlist
  Waitlists student to a section

* ### /student/cancel
  Removes student from a section

* ### /student/finalize
  Finalizes the schedule of a student


## /auth
Contains functions that manages the session.

* ### /auth/login
  Tries to authenticate with given credentials and returns session key

* ### /auth/logout
  Terminates session of given session key

## /subjects
Contains functions that returns data from the list of sections

* ### /subjects/[subject]
  Returns subject information and list of sections

* ### /subjects/[subject]/sections
  Returns list of sections of a subject


* ### /subjects/[subject]/title
  Returns course title of a subject

* ### /subjects/search
  Returns a list containing search keys
