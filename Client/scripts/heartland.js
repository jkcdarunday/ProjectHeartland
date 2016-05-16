'use strict';

function HeartLand(mainui) {
  this.user = null;
  this.ajax = new Ajax();
  this.ui = mainui;

  this.ui.bind(this);
  var $ = this;
  var classes = $_CLASS('menuChoice');
  for (var i = 0; i < classes.length; i++) {
    classes[i].onclick = function() {
      // $.updateSection(this, this.id);
    }
  }

  if (cookie.get('sessionID') != null) {
    var user = cookie.get('user');
    $_ID('login').style.display = 'none';
    setTimeout(function() {
      $_ID('login').style.display = 'block';
    }, 300);
    this.ui.login(JSON.parse(user));
    // this.updateSection($_ID('home'), 'home');
  }

  window.addEventListener('storage', function(e) {
    if (e.key === 'loggedin') {
      if (e.newValue === 'false') {
        $.logout();
      } else {
        var user = cookie.get('user');
        $.ui.login(JSON.parse(user));
        // $.updateSection($_ID('home'), 'home');
      }
    }
  }, false);
}

HeartLand.prototype.login = function(username, password) {
  var $ = this;
  var url = config.server_url + '/auth/login';
  var params = '?username=' + username + '&password=' + password;
  this.ajax.request('post', url + params, function(r) {
    var res;

    try {
      console.log(r)
      res = JSON.parse(r);
      console.log(res)
    } catch (e) {
      alert('The server has responded with invalid data.');
    }

    switch (res.result) {
      case 0:
        $.user = {
          'name': username,
          'units': 18,
          'icon': './images/account-circle-icon.png'
        };
        $.ui.login($.user);
        cookie.set('user', JSON.stringify($.user));
        cookie.set('sessionID', res.key);
        localStorage.loggedin = 'true';
        break;
      case -1: // wrong password
        return alert('Error: Incorrect password.');
        break;
      case -2: // user does not exist
        return alert('Error: User does not exist.');
        break;
    }
  });
}

HeartLand.prototype.logout = function() {
  var $ = this;
  var url = config.server_url + '/auth/logout';
  var params = '?session=' + cookie.get('sessionID');

  this.ajax.request('delete', url + params, function(r) {
    $.user = null;
    cookie.remove('user');
    cookie.remove('sessionID');
    localStorage.loggedin = 'false';
    $.ui.logout();
  });
}

HeartLand.prototype.updateSection = function(elt, section) {
  var $ = this;

  this.ui.setLoading(section + 'Section');

  $.ajax.request('get', config.server_url, function(r) {
    var res;
    try {
      res = JSON.parse(r);
      $.ui.updateContent.call(elt, res);
    } catch (e) {
      return alert('The server has responded with invalid data.');
    }
  });
};
