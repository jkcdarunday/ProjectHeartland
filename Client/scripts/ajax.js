'use strict';

var createXMLHttpRequest = function() {
  try {
    return new XMLHttpRequest();
  } catch (e) {}
  try {
    return new ActiveXObject("Msxml2.XMLHTTP");
  } catch (e) {}
  try {
    return new ActiveXObject("Msxml2.XMLHTTP.6.0");
  } catch (e) {}
  try {
    return new ActiveXObject("Msxml2.XMLHTTP.3.0");
  } catch (e) {}
  try {
    return new ActiveXObject("Microsoft.XMLHTTP");
  } catch (e) {}
  throw new Error("This browser does not support XMLHttpRequest.");
};

function Ajax() {
  this.xhr = createXMLHttpRequest();
  this.xhr.timeout = 10000;

  this.xhr.ontimeout = function() {
    alert("The previous request timed out.");
  }

  this.xhr.onerror = function() {
    alert("An error has occured while attempting to send a request to the server.");
  }
}

Ajax.prototype.request = function(method, url, fn) {
  this.xhr.onreadystatechange = function() {
    if (this.readyState === this.DONE) {
      if (this.status === 200) {
        fn(this.responseText);
      } else {
        return alert('Server responded with code: ' + this.status);
      }
    }
  }

  this.xhr.open(method, encodeURI(url), true);
  this.xhr.send(null);
}

// Ajax.prototype.get = function(url, fn) {
//   this.xhr.onreadystatechange = function() {
//     if (this.readyState === this.DONE) {
//       if (this.status === 200) {
//         fn(this.responseText);
//       } else {
//         return alert('Server response code: ' + this.status);
//       }
//     }
//   }
//
//   this.xhr.open('GET', encodeURI(url), true);
//   this.xhr.send(null);
// }
//
// Ajax.prototype.post = function(url, data, fn) {
//   this.xhr.onreadystatechange = function() {
//     if (this.readyState === this.DONE) {
//       if (this.status === 200) {
//         fn(this.responseText);
//       } else {
//         return alert('Server response code: ' + this.status);
//       }
//     }
//   }
//
//   this.xhr.open('POST', encodeURI(url), true);
//   this.xhr.setRequestHeader("Content-type", "application/x-www-form-urlencoded");
//   this.xhr.send(encodeURI(data));
// }
//
// Ajax.prototype.put = function(url, data, fn) {
//   this.xhr.onreadystatechange = function() {
//     if (this.readyState === this.DONE) {
//       if (this.status === 200) {
//         fn(this.responseText);
//       } else {
//         return alert('Server response code: ' + this.status);
//       }
//     }
//   }
//
//   this.xhr.open('POST', encodeURI(url), true);
//   this.xhr.setRequestHeader("Content-type", "application/x-www-form-urlencoded");
//   this.xhr.send(encodeURI(data));
// }
//
// Ajax.prototype.delete = function(url, data, fn) {
//   this.xhr.onreadystatechange = function() {
//     if (this.readyState === this.DONE) {
//       if (this.status === 200) {
//         fn(this.responseText);
//       } else {
//         return alert('Server response code: ' + this.status);
//       }
//     }
//   }
//
//   this.xhr.open('POST', encodeURI(url), true);
//   this.xhr.setRequestHeader("Content-type", "application/x-www-form-urlencoded");
//   this.xhr.send(encodeURI(data));
// }
