"use strict"

const path = require('path');
const {app, BrowserWindow} = require('electron');

let mainWindow;

// Keep a global reference of the window object, if you don't, the window will
// be closed automatically when the JavaScript object is garbage collected.

function createWindow () {
// Create the browser window.
mainWindow = new BrowserWindow({
    width: 900,
    height: 750,
    resizable: true,
    icon: path.join(__dirname,'assets/logo.png'),
    webPreferences: {
        nodeIntegration: true,
        contextIsolation: true,
        enableRemoteModule: false,
        preload: path.join(__dirname, 'preload.js')
    }
})

// and load the index.html of the app.
mainWindow.loadFile(`views/index.html`)

// Wait for the window to finish loading
mainWindow.webContents.on('did-finish-load', () => {
    // Send the value 10 to the renderer process
});
// Open the DevTools.
// mainWindow.webContents.openDevTools()
mainWindow.once('ready-to-show', () => {
    //autoUpdater.checkForUpdatesAndNotify();
});

// Emitted when the window is closed.
mainWindow.on('closed', function () {
    // Dereference the window object, usually you would store windows
    // in an array if your app supports multi windows, this is the time
    // when you should delete the corresponding element.
    mainWindow = null
})
}

// This method will be called when Electron has finished
// initialization and is ready to create browser windows.
// Some APIs can only be used after this event occurs.
app.on('ready', createWindow)

// Quit when all windows are closed.
app.on('window-all-closed', function () {
// On macOS it is common for applications and their menu bar
// to stay active until the user quits explicitly with Cmd + Q
if (process.platform !== 'darwin') app.quit()
})

app.on('activate', function () {
    // On macOS it's common to re-create a window in the app when the
    // dock icon is clicked and there are no other windows open.
    if (mainWindow === null) createWindow()
})    
