'use strict';

function UserInterface(root) {
  root.onresize = function() {
    var classes = $_CLASS('rightSection');
    for (var i = 0; i < classes.length; i++) {
      classes[i].width = (255 - root.innerWidth) + 'px';
    }
  };
}

UserInterface.prototype.login = function(user) {
  $_ID('login').className += ' loginInactive';
  $_ID('name').innerHTML = user.name
  $_ID('lastLogin').innerHTML = user.lastLogin;
  $_ID('units').innerHTML = user.units;
  $_ID('icon').src = user.icon;
}

UserInterface.prototype.logout = function() {
  $_ID('login').className = 'section';
  $_ID('name').innerHTML = '';
  $_ID('lastLogin').innerHTML = '';
  $_ID('units').innerHTML = '';
  $_ID('icon').src = '';

  var items = $_ID('menuItems').children;
  var $ = this;
  for (var i = 0; i < items.length; i++) {
    items[i].className = items[i].className.split(' ').filter(function(e) {
      return e != 'menuActive';
    });
  }

  setTimeout(function() {
    $.updateContent.call(items[0]);
  }, 2000);
};

UserInterface.prototype.bind = function($) {
  $_ID('mainform').onsubmit = function() {
    $.login($_ID('uname').value, $_ID('upass').value);
    return false;
  };

  $_ID('logout').onclick = function() {
    $.logout();
  };
};

UserInterface.prototype.updateContent = function(res) {
  var classes = $_CLASS('menuChoice');
  if (classes === null) {
    return;
  }
  var targetSection = $_ID(this.id + 'Section');
  if (targetSection == null) {
    return;
  }

  if (res !== undefined) {
    targetSection.innerHTML = '';
    for (var i = 0; i < res.data.length; i++) {
      targetSection.innerHTML += '<article class="newsArticle">' + "\n" + '<header class="newsHeader">' + res.data[i].title + '</header>' + "\n" + res.data[i].body + "\n" + '<footer class="newsFooter">- ' + res.data[i].author + ' (' + res.data[i].date + ')</footer>' + "\n" + '</article>' + "\n";
    }
  }

  for (var i = 0; i < classes.length; i++) {
    classes[i].className = 'menuChoice';
    var tmp = $_ID(classes[i].id + 'Section');

    if (tmp != null) {
      if (tmp.getAttribute('active') === 'true') {
        if (tmp.getAttribute('index') < targetSection.getAttribute('index')) {
          tmp.className = 'rightSection exitToLeft';
          targetSection.className = 'rightSection enterFromRight';
        } else if (tmp.getAttribute('index') > targetSection.getAttribute('index')) {
          tmp.className = 'rightSection exitToRight';
          targetSection.className = 'rightSection enterFromLeft';
        }

        tmp.setAttribute('active', 'false');
        targetSection.setAttribute('active', 'true');
      }
    }
  }

  this.className += ' menuActive';
};

UserInterface.prototype.setLoading = function(id) {
  console.log(id, 'is loading...')
  $_ID(id).innerHTML = '<div class="loading"></div>';
}
