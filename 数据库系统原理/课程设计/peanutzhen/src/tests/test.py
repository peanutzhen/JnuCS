from app.models import (
    User,
    Journal,
    Email,
    Editor,
    Organizer
)

# 初始化数据库 用于开发时测试
def init_database(app,db):
    admin = User(
        'admin',
        'admin@6324.com',
        'iamadmin',
        True
    )
    # Chinese Medical Journal
    CMJ = Journal(
        '0366-6999',
        '11-2154/R',
        'Chinese Medical Journal',
        'Chinese Medical Journal',
        1887,
        24,
        '北京东四西大街42号中华医学会',
        '100710',
        '8610-85158321',
        '8610-85158333'
    )
    editor1 = Editor('照日格图')
    editor2 = Editor('甄洛生牛逼甄洛生牛逼甄洛生牛逼')
    organ1 = Organizer('中华医学会')
    organ2 = Organizer('甄洛生牛逼甄洛生牛逼甄洛生牛逼甄洛生牛逼甄洛生牛逼')
    

    with app.app_context():
        db.drop_all()
        db.create_all()
        # 创建管理员账户
        db.session.add(admin)
        # 为CMJ添加邮箱/主编/主办单位
        db.session.add(Email('cmj@cma.org.cn',CMJ))
        CMJ.editors.append(editor1)
        CMJ.editors.append(editor2)
        CMJ.organizers.append(organ1)
        CMJ.organizers.append(organ2)
        db.session.commit()
