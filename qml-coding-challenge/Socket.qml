import QtQuick 2.12
import QtQuick.Window 2.12
import QtWebSockets 1.1
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12
import QtQuick.Controls.Material 2.12
import QtQml 2.0

// all websocket handling occurs here
// I have moved this component back to main.qml a few times
// it is a tad finnecky and doesn't always work perfectly.
// But, it works well enough to have it here for legibility
WebSocket {
  // id is socket, which is referenced by other code
  id: socket
  active: true
  url: "ws://localhost:8080"

  // bulk of the handling is here
  onTextMessageReceived: function(message){
    // first the data is parsed
    // similiar to the server, the data can take on many forms because of this
    var data = JSON.parse(message);
    // if the type is "msg"
    // global chat
    if (data.type === "msg") {
      // ensures you are in global to recieve the message
      if(root.global === true) {
        // uses locale if a timestamp wasn't provided;
        // used when bots share info
        var locale = new Date().toLocaleTimeString(Qt.locale())
        var stamp;
        if(data.time) stamp = data.time
        else stamp = locale
        // the message model is appended with the data: author, message, and date
        listModel.append({"author": data.username, "message": data.text, "date": stamp})
        //msgList.contentY = 10000; // I have this commented to test its use in main.qml
      }
    }
    // used for personal messages
    else if (data.type === "pm") {
      // global is false, this prevents being PM'd in a different chat window
      if(root.global === false) {
        // uses locale if a timestamp wasn't provided;
        locale = new Date().toLocaleTimeString(Qt.locale())
        if(data.time) stamp = data.time
        else stamp = locale
        listModel.append({"author": data.username, "message": data.text, "date": stamp})
        //msgList.contentY = 10000; // I have this commented to test its use in main.qml

      }
    }
    // used on client disconnect
    // loops through the model and removes the correct user from list
    else if(data.type === "client") {
        for(var z = 0; z < activeUsers.length; z++) {
            if(userModel.get(z).user === data.name) {
                userModel.remove(z, 1);
            }
        }
        // changes the active users array as well
        for(var w = 0; w < activeUsers.length; w++) {
          if(activeUsers[w] === data.name) {
            activeUsers.splice(w, 1);
          }
        }
    }
    // finally, if we aren't in global, a DM, or a leaving client
    // this is used to add new users to the list
    else {
      var add = true; // true until false
      var users = JSON.parse(message);
      for(var i = 0; i < users.length; i ++) {
        add = true;
        // loops through activeUsers to see if the user exists
        for(var j = 0; j < activeUsers.length; j++) {
          if(users[i].name === activeUsers[j]) {
            add = false;
          }
        }
        // if add is still true in the end, the user can be appended
        // and the activeUsers gets updated
        if(add === true) {
          userModel.append({"user": users[i].name});
          activeUsers[j] = users[i].name
        }
      }
    }
  }
}
