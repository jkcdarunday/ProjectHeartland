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
      $.updateSection(this, this.id);
    }
  }

  if (cookie.get('sessionID') != null) {
    var user = cookie.get('user');
    $_ID('login').style.display = 'none';
    setTimeout(function() {
      $_ID('login').style.display = 'block';
    }, 300);
    this.ui.login(JSON.parse(user));
    this.updateSection($_ID('home'), 'home');
  }

  window.addEventListener('storage', function(e) {
    if (e.key === 'loggedin') {
      if (e.newValue === 'false') {
        $.logout();
      } else {
        var user = cookie.get('user');
        $.ui.login(JSON.parse(user));
        $.updateSection($_ID('home'), 'home');
      }
    }
  }, false);
}

HeartLand.prototype.getUser = function() {
  return this.user;
}

HeartLand.prototype.login = function(username, password) {
  var $ = this;

  this.ajax.post('process.php?p=login', 'user=' + username + '&password=' + password, function(r) {
    var res;

    try {
      res = JSON.parse(r);
    } catch (e) {
      alert('The server has responded with invalid data.');
    }

    if (res.user) {
      $.user = res.user;
      $.ui.login($.user);
      cookie.set('user', JSON.stringify($.user));
      cookie.set('sessionID', JSON.stringify($.user.sessionID));
      localStorage.loggedin = 'true';
      $.updateSection($_ID('home'), 'home');
    } else {
      return alert(res.message);
    }
  });
}

HeartLand.prototype.logout = function() {
  var $ = this;

  this.ajax.post("process.php?p=logout", 'sessid=' + this.sessionID, function(r) {
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

  $.ajax.get("process.php?p=" + section, function(r) {
    var res;
    try {
      res = JSON.parse(r);
      $.ui.updateContent.call(elt, res);
    } catch (e) {
      return alert('The server has responded with invalid data.');
    }
  });
};
