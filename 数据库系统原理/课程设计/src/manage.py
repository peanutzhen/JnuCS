from app import (
    create_app,
    db
)
from os import environ
from flask_script import Manager
from util import (
    extract_example_dataset,
    create_admin,
    add_journal
)

# 运行
if __name__ == "__main__":
    env_name = environ.get('app_env') or 'default'
    app = create_app(env_name)
    
    # 建立表
    with app.app_context():
        db.create_all()

    # flask_script...
    manager = Manager(app)

    @manager.command
    def initdb():
        "用 dataset.pdf 初始化数据库"
        # 创建管理员
        create_admin(app, db)
        # 注入期刊数据
        journals = extract_example_dataset()
        for journal in journals:
            add_journal(app, db, journal)

    @manager.command
    def cleandb():
        "清空数据库"
        with app.app_context():
            db.drop_all()

    manager.run()