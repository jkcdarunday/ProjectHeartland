'use strict';

var createXMLHttpRequest = function () {
    try { return new XMLHttpRequest(); } catch (e) {}
    try { return new ActiveXObject("Msxml2.XMLHTTP"); } catch (e) {}
    try { return new ActiveXObject("Msxml2.XMLHTTP.6.0"); } catch (e) {}
    try { return new ActiveXObject("Msxml2.XMLHTTP.3.0"); } catch (e) {}
    try { return new ActiveXObject("Microsoft.XMLHTTP"); } catch (e) {}
    throw new Error("This browser does not support XMLHttpRequest.");
};

function Ajax(){
    this.xmlr = createXMLHttpRequest();
    this.xmlr.timeout = 10000;
    this.xmlr.ontimeout = function () { alert("The previous request timed out."); }
    this.xmlr.onerror = function () { alert("An error has occured while attempting to send a request to the server."); }
}

Ajax.prototype.get = function(url, fn){
    this.xmlr.onreadystatechange = function () {
        if(this.readyState == 4){
            fn(this.responseText);
        }
    }

    this.xmlr.open("GET", url, true);
    this.xmlr.send();
}

Ajax.prototype.post = function(url, data, fn){
    this.xmlr.onreadystatechange = function () {
        if(this.readyState == 4) {
            if(this.status == 0) { alert("A server timeout has occured."); }
            else if(this.status != 200) { alert("The server responded with a status code of " + this.status + "."); }
            else { fn(this.responseText); }
        }
    }

    this.xmlr.open("POST", url, true);
    this.xmlr.setRequestHeader("Content-type", "application/x-www-form-urlencoded");
    this.xmlr.send(data);
}
