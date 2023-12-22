const {contextBridge, ipcRenderer} = require("electron");

let validChannels = [
    "create"
];

contextBridge.exposeInMainWorld("api", {
    send: (channel, data) => {
      try {
        if (validChannels.includes(channel)) {
          ipcRenderer.send(channel, data);
        }  
      } catch(error) {
      }
    },
    receive: (channel, func) => {
      try {
        if (validChannels.includes(channel)) {
          ipcRenderer.on(channel, function(event, args) {
            func(channel, event, args)
          });
        }
      } catch(error) {
      }
    }
  });
  
  var pjson = require('./package.json');
  localStorage.setItem('version', pjson.version);
