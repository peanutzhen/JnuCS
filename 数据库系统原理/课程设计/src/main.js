const { 
	app, 
	BrowserWindow
} = require('electron')

var win = null;

function createWindow () {
	win = new BrowserWindow({
		width: 360,
		height: 490,
		frame: false,
		webPreferences: {
			nodeIntegration: true,
			enableRemoteModule: true
		}
	})
	win.isResizable(true)
	// 进入登陆界面
	win.loadURL('http://localhost:5000/login')
}

app.whenReady().then(createWindow)

app.on('window-all-closed', () => {
    app.quit()
})

app.on('activate', () => {
    if (BrowserWindow.getAllWindows().length === 0) {
        createWindow()
    }
})
