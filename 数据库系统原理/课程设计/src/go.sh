#!/bin/sh

# 判断参数完整性
if [ -z $1 ]
then
    echo "用法: ./go [production/dev]\ndev 开发环境\nproduction 生产环境"
    exit 1
fi

export app_env=$1
echo "正在使用 ${1} 环境..."

# 进入虚拟 Python 环境
source venv/bin/activate

# 初始化数据库环境
python3 manage.py cleandb
python3 manage.py initdb

# 运行 Flask 服务器 放到后台
python3 manage.py runserver -d &
sleep 3     #  给服务器一点时间^ ^

# 运行 Electron
npm start

# 停止 Flask
kill %1