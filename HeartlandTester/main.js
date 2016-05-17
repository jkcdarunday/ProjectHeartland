var subjects = {}

$.ajax({
  url: 'subjects.json',
  success: function(data) {
    console.log(data)
    subjects = data.subjects
  }
})

function login() {
  $.ajax({
    type: 'POST',
    url: 'http://localhost:3000/auth/login?username=' + $("#username").val() + '&password=' + $("#password").val(),
    success: function(data) {
      var res = JSON.parse(data);
      if (res.key) {
        $("#session").val(res.key);
        Materialize.toast("Successfully logged in.", 1000);
      } else {
        Materialize.toast("Failed to logged in.", 1000);
      }
      console.log(res)
    }
  })
  return false;
}

function logout() {
  $.ajax({
    type: 'POST',
    url: 'http://localhost:3000/auth/logout?session=' + $("#session").val(),
    success: function(data) {
      var res = JSON.parse(data);
      if (res.result == 0) {
        $("#session").val('-');
        Materialize.toast("Successfully logged out.", 1000);
      } else {
        Materialize.toast("Failed to logged out.", 1000);
      }

    }
  })
  return false
}

function get_profile() {
  $.ajax({
    type: 'GET',
    url: 'http://localhost:3000/student/profile?session=' + $("#session").val(),
    success: function(data) {
      var res = JSON.parse(data);
      $("#student_profile").html(
        `<td>${res.data.student_number}</td>
        <td>${res.data.first_name}</td>
        <td>${res.data.middle_name}</td>
        <td>${res.data.last_name}</td>
        <td>${res.data.curriculum}</td>
        <td>${res.data.standing}</td>
        <td>${res.data.total_units}</td>
        <td>${res.data.max_units}</td>`
      )
      console.log(res)
    }
  })
  return false
}

function get_schedule() {
  $.ajax({
    type: 'GET',
    url: 'http://localhost:3000/student/schedule?session=' + $("#session").val(),
    success: function(data) {
      var res = JSON.parse(data);
      var html = ''

      var c = initializeSched($("#schedule")[0]);

      for (subject in res.data) {
        var section = res.data[subject]
        let subdata = subjects[subject][section]
        drawSchedule(c, subdata.hours[0], subdata.hours[1], subdata.days, subject, subdata.room, section)
        if (subdata.lecture) {
          let lecsubdata = subjects[subject][subdata.lecture];
          drawSchedule(c, lecsubdata.hours[0], lecsubdata.hours[1], lecsubdata.days, subject, lecsubdata.room, subdata.lecture);
        }
        html += `
        <tr><td>${subject}</td>
        <td>${section}</td>
        <td>${subdata.time}</td>
        <td>${subdata.days}</td>
        <td>${subdata.units}</td>
        <td>${subdata.room}</td>
        <td>${subdata.instructor}</td></tr>`
      }
      $("#student_schedule").html(html)
      console.log(res)
    }
  })
  return false
}

function enlist() {
  $.ajax({
    type: 'PUT',
    url: encodeURI('http://localhost:3000/student/schedule?' + 'session=' + $('#session').val() + '&subject=' + $('#subject').val() + '&section=' + $('#section').val()),
    success: function(data) {
      var res = JSON.parse(data);
      if (res.result == 0) Materialize.toast("Successfully enlisted.", 1000);
      else Materialize.toast("Failed to enlist.", 1000);
      console.log(res)
    }
  })
  return false
}

function cancel() {
  $.ajax({
    type: 'DELETE',
    url: encodeURI('http://localhost:3000/student/schedule?' + 'session=' + $('#session').val() + '&subject=' + $('#subject').val() + '&section=' + $('#section').val()),
    success: function(data) {
      var res = JSON.parse(data);
      if (res.result == 0) Materialize.toast("Successfully cancelled.", 1000);
      else Materialize.toast("Failed to cancel.", 1000);
      console.log(res)
    }
  })
  return false
}

function waitlist() {
  $.ajax({
    type: 'PUT',
    url: encodeURI('http://localhost:3000/student/waitlist?' + 'session=' + $('#session').val() + '&subject=' + $('#subject').val() + '&section=' + $('#section').val()),
    success: function(data) {
      var res = JSON.parse(data);
      if (res.result > 0) Materialize.toast("Successfully waitlisted.", 1000);
      else Materialize.toast("Waitlisting failed.", 1000);
      console.log(res)
    }
  })
  return false
}

function unwaitlist() {
  $.ajax({
    type: 'DELETE',
    url: encodeURI('http://localhost:3000/student/waitlist?' + 'session=' + $('#session').val() + '&subject=' + $('#subject').val() + '&section=' + $('#section').val()),
    success: function(data) {
      var res = JSON.parse(data);
      if (res.result == 0) Materialize.toast("Successfully unwaitlisted.", 1000);
      else Materialize.toast("Unwaitlisting failed.", 1000);
      console.log(res)
    }
  })
  return false
}
