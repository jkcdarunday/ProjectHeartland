var subjects = {}

// get list of subjects
$.ajax({
  url: 'subjects.json',
  success: function(data) {
    subjects = data.subjects;
  }
});

// bind a storage event listener
window.addEventListener('storage', function(e) {
  if (e.key === 'loggedin') {
    if (e.newValue === 'false') {
      $('#main').hide();
      $('#login-form').show();
    } else {
      $('#login-form').hide();
      $('#main').show();
    }
  }
}, false);

// safe initialization
$(document).ready(function() {
  $('#main').hide();
  $('ul.tabs').tabs();
  get_profile();
  $('#enlistment-content').hide();
  // $('#dreamsched-content').hide();

  $('#username').prop('required', true);
  $('#password').prop('required', true);
  // if something went wrong, ensure to hide input fields below
  $('#student-number').parent().hide();
  $('#password-confirm').parent().hide();

  if (localStorage.loggedin === 'true') {
    $('#login-form').hide();
    $('#main').show();
  } else {
    $('#main').hide();
    $('#login-form').show();
    $('#student-number').parent().hide();
    $('#password-confirm').parent().hide();
  }

  $('#main-form').submit(login_wrapper);
  // $('#mainform').submit(register_wrapper);
  $('#login-btn').click(function() {
    $('#student-number').prop('required', false);
    $('#password-confirm').prop('required', false);
    $('#student-number').parent().hide();
    $('#password-confirm').parent().hide();
  });
  $('#register-btn').click(function() {
    Materialize.toast('Registration disabled, contact admin', 1000);
    return false;
    $('#student-number').prop('required', true);
    $('#password-confirm').prop('required', true);
    $('#student-number').parent().show();
    $('#password-confirm').parent().show();
    $('#username').val('');
    $('#password').val('');
  })
  $('#logout').click(logout_wrapper);
  $('#home').click(home_wrapper);
  $('#enlistment').click(enlistment_wrapper);
  // $('#dreamsched').click(dreamsched_wrapper);

});

function login_wrapper() {
  $('#dreamsched-content').hide();
  $('#enlistment-content').hide();
  $('#home-content').show();
  return login();
}

function logout_wrapper() {
  return logout();
}

function register_wrapper() {
  return register();
}

function home_wrapper() {
  $('#dreamsched-content').hide();
  $('#enlistment-content').hide();
  $('#home-content').show();
  $('#dreamsched').removeClass('menuActive');
  $('#enlistment').removeClass('menuActive');
  $('#home').addClass('menuActive');
  return false;
}

function enlistment_wrapper() {
  $('#home-content').hide();
  $('#dreamsched-content').hide();
  $('#enlistment-content').show();
  $('#dreamsched').removeClass('menuActive');
  $('#home').removeClass('menuActive');
  $('#enlistment').addClass('menuActive');
  return get_schedule();
}
//
// function dreamsched_wrapper() {
//   $('#home-content').hide();
//   $('#enlistment-content').hide();
//   $('#dreamsched-content').show();
//   $('#home').removeClass('menuActive');
//   $('#enlistment').removeClass('menuActive');
//   $('#dreamsched').addClass('menuActive');
//   return false;
// }
// login handler
function login() {
  if (cookie.get('session') === null) {
    var username = $("#username").val(),
      password = $("#password").val();

    $.ajax({
      type: 'POST',
      url: config.server + '/auth/login?username=' + username + '&password=' + password,
      success: function(data) {
        var res = JSON.parse(data);
        console.log(res)
        switch (res.result) {
          case 0:
            cookie.set('session', res.key);
            cookie.set('account', JSON.stringify({
              'username': username,
              'password': password
            }));
            localStorage.loggedin = 'true';
            $('#login-form').hide();
            $('#main').show();
            Materialize.toast("Successfully logged in.", 1000);
            break;
          case -1:
            Materialize.toast('Incorrect password.', 1000);
            break;
          case -2:
            Materialize.toast('User does not exist.', 1000);
            break;
        }
      }
    });
  } else { // already logged in
    $('#login-form').hide();
    $('#main').show();
  }

  return false;
}

// logout handler
function logout() {
  $.ajax({
    type: 'DELETE',
    url: config.server + '/auth/logout?session=' + cookie.get('session'),
    success: function(data) {
      var res = JSON.parse(data);
      if (res.result == 0) {
        cookie.remove('session');
        cookie.remove('account');
        localStorage.loggedin = 'false';
        $('#main').hide();
        $('#login-form').show();
        Materialize.toast("Successfully logged out.", 1000);
      } else {
        Materialize.toast("Failed to logged out.", 1000);
      }
    }
  });

  return false;
}

// register handler
function register() {
  var student_number = $('#student-number').val(),
    username = $('#username').val(),
    password = $('#password').val(),
    password_confirm = $('#password-confirm').val();

  if (password === password_confirm) {
    $.ajax({
      type: 'PUT',
      url: config.server + '/auth/register/' + student_number + '?username=' + username + '&password=' + password,
      success: function(data) {
        var res = JSON.parse(data);
        if (res.key) {
          $("#session").val(res.key);
          $('#student-number').parent().hide();
          $('#password-confirm').parent().hide();
          Materialize.toast("Successfully registered.", 1000);
        } else {
          Materialize.toast("Failed to register. Contact admin for assistance.", 1000);
        }
      }
    })
  } else {
    Materialize.toast("Passwords do not match.", 1000);
  }

  return false;
}

// profile handler
function get_profile() {
  $.ajax({
    type: 'GET',
    url: config.server + '/student/profile?session=' + cookie.get('session'),
    success: function(data) {
      var res = JSON.parse(data);
      var fullname = res.data.lastname + ', ' + res.data.first_name + ' ' + res.data.middle_name;
      $('#fullname').html('<u>' + fullname + '</u>');
      $('#info_student_number').html('<u>' + res.data.student_number + '</u>');
      $('#info_curriculum').html('<u>' + res.data.curriculum + '</u>');
      $('#info_standing').html('<u>' + res.data.standing + '</u>');
      $('#info_total_units').html('<u>' + res.data.total_units + '</u>');
      $('#info_max_units').html('<u>' + res.data.max_units + '</u>');
    }
  })
  return false;
}

// schedule handler
function get_schedule() {
  $.ajax({
    type: 'GET',
    url: config.server + '/student/schedule?session=' + cookie.get('session'),
    success: function(data) {
      var res = JSON.parse(data);
      var html = '';

      var c = initializeSched($("#sched")[0]);

      for (subject in res.data) {
        var section = res.data[subject];
        var subdata = subjects[subject][section];
        drawSchedule(c, subdata.hours[0], subdata.hours[1], subdata.days, subject, subdata.room, section)
        if (subdata.lecture) {
          var lecsubdata = subjects[subject][subdata.lecture];
          drawSchedule(c, lecsubdata.hours[0], lecsubdata.hours[1], lecsubdata.days, subject, lecsubdata.room, subdata.lecture);
        }
        html += `
        <tr><td>${subject}</td>
        <td>${section}</td>
        <td>${subdata.time}</td>
        <td>${subdata.days}</td>
        <td>${subdata.units}</td>
        <td>${subdata.room}</td>
        <td>${subdata.instructor}</td>
        <td><button onclick="return cancel();" class="btn-floating btn-small waves-effect waves-light red action-btn">
        <i class="material-icons">clear</i></button></td></tr>`
      }
      $("#student_schedule").html(html);
    }
  })
  return false;
}

// enlisting handler
function enlist(subj, sec) {
  $.ajax({
    type: 'PUT',
    url: encodeURI(config.server + '/student/schedule?' + 'session=' + cookie.get('session') + '&subject=' + subj + '&section=' + sec),
    success: function(data) {
      var res = JSON.parse(data);
      if (res.result == 0) Materialize.toast("Successfully enlisted.", 1000);
      else Materialize.toast("Failed to enlist.", 1000);
      console.log(res);
    }
  })
  return false;
}

// cancelling handler
function cancel(subj, sec) {
  Materialize.toast('Cancel feature disabled', 1000);
  return false;
  $.ajax({
    type: 'DELETE',
    url: encodeURI(config.server + '/student/schedule?' + 'session=' + cookie.get('session') + '&subject=' + subj + '&section=' + sec),
    success: function(data) {
      var res = JSON.parse(data);
      if (res.result == 0) {
        Materialize.toast("Successfully cancelled.", 1000);
      } else Materialize.toast("Failed to cancel.", 1000);
      console.log(res)
    }
  });
  return false;
}

// waitlisting handler
function waitlist(subj, sec) {
  $.ajax({
    type: 'PUT',
    url: encodeURI('http://localhost:3000/student/waitlist?' + 'session=' + $('#session').val() + '&subject=' + subj + '&section=' + sec),
    success: function(data) {
      var res = JSON.parse(data);
      if (res.result > 0) Materialize.toast("Successfully waitlisted.", 1000);
      else Materialize.toast("Waitlisting failed.", 1000);
      console.log(res)
    }
  })
  return false;
}

// cancel waitlist handler
function unwaitlist(subj, sec) {
  $.ajax({
    type: 'DELETE',
    url: encodeURI('http://localhost:3000/student/waitlist?' + 'session=' + $('#session').val() + '&subject=' + subj + '&section=' + sec),
    success: function(data) {
      var res = JSON.parse(data);
      if (res.result == 0) Materialize.toast("Successfully unwaitlisted.", 1000);
      else Materialize.toast("Unwaitlisting failed.", 1000);
      console.log(res)
    }
  })
  return false;
}
