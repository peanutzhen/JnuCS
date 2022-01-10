const { BrowserWindow } = require('electron').remote
const fs = require('fs')
const path = require('path')
const os = require('os')

// 获取当前窗口
let win = BrowserWindow.getAllWindows()[0];

// 重新设置大小
if(win.getSize()[0] != 1024)
    win.setSize(1024,630);


	  
var report_btn = document.getElementById('gen_report');

report_btn.addEventListener('click', () => {
	// 新建一个隐藏的页面
	const pdfWin = new BrowserWindow({
		frame: true,
		show: false,
		webPreferences: {
			nodeIntegration: true,
			nativeWindowOpen: true
		}
	})

	// 前往报表页面
	pdfWin.loadURL('http://localhost:5000/use_for_reporting')

	// 生成 PDF
	pdfWin.webContents.on('did-finish-load', () => {
		// Use default printing options
		pdfWin.webContents.printToPDF({
			printBackground: true
		}).then(data => {
			const pdfPath = path.join('./report.pdf')
			fs.writeFile(pdfPath, data, (error) => {
				if (error) throw error
				console.log(`Wrote PDF successfully to ${pdfPath}`)
			})
			}).catch(error => {
			console.log(`Failed to write PDF to ${pdfPath}: `, error)
		})
	})

	// 提示成功消息
	const notification = {
		title: '消息',
		body: '报表已生成'
	}

	const myNotification = new window.Notification(notification.title, notification)
      
    myNotification.onclick = () => {
        console.log('点你妈')
    }
})
