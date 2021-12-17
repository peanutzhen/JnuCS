# 暨大数据库实验设计

暨南大学数据库系统概念实验课项目，这门课的老师真的太拉了，实验课不上，第一周一上来就要我们写个大项目作为期末成绩，害，需求又说不好，就连数据集还是pdf，还好可以解析自动添加数据，不然我真的***。还要搞什么报表，我爆你老表啊艹。

**2021.2.10update:** 还只给了77分（实验课）草= =，可能我这个是用前端写的界面而不是JavaFX或者Qt。

## Introduction

本项目主题是期刊管理系统（就是对期刊CURD的垃圾软件），一个小型跨平台桌面应用，后端基于Flask，鄙人不是很会前端，所以用了Bootstrap官网的模版作为GUI设计。同时使用Electron桌面化。

## Preparing

1. 下载项目至您的电脑，该软件跨平台，已在Windows/Mac测试：

   ```bash
   git clone https://github.com/astzls213/database-HW.git
   cd database-HW
   ```
   
2. 请确保安装[Python3](https://www.python.org/downloads/)，并跟随下面命令：

   ```bash
   # if not work, then: pip install virtualenv
   virtualenv venv
   # For Mac/Linux
   source venv/bin/activate
   # For Windows
   venv\Scripts\activate.bat
   pip install -r requirements.txt
   ```

   作者使用的Python版本是3.7.2，如其他版本报错请联系作者或提Issue，我会随时回复。下载包需要点时间，如果你网络不好。

3. 请确保已安装[MySQL]()，现在先做下面的工作：

   ```sql
   # 登录MySQL
   $ mysql -u root -p
   # 创建账户
   create user dev identified by 'usefordev';
   create user dbhw identified by 'iamp@$$wd';
   # 创建数据库
   create database dev_db;
   create database hw_db;
   # 分配权限
   grant all on dev_db.* to dev;
   grant all on hw_db.* to dbhw;
   ```

4. 请确保已安装[NodeJS](https://nodejs.org/en/)，现在安装electron：

   ```bash
   node -v && npm -v
   # if not work, it told you node.js not installed.
   npm install
   ```

   需要花点时间，如果你网络不好。

5. 现在一切就绪，我们随时可以启动：

   ```bash
   # For Mac/Linux
   ./go dev
   # For Windows
   python manage.py cleandb
   python manage.py initdb
   python manage.py runserver -d
   npm start
   # 当进入登陆界面时，请使用管理员账户
   # 邮箱: astzls213@gmail.com
   # 密码: iamadmin
   # 注册只能注册普通用户，没有增删改的权限，只有查和报表的权限
   # 管理员可以为所欲为
   ```

   Windows这么复杂是因为我不会写bat脚本，你们谁会可以帮我写个然后Pull Request。

## Demo

登陆界面

![login](./login.png)

注册界面

![register](./register.png)

主界面

![main](./main.png)

## Uninstall

```bash
# Just do this.
cd .. && rm -rf database-HW
```

