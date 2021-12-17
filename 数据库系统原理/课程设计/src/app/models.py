from werkzeug.security import(
    generate_password_hash,
    check_password_hash
)
from flask_sqlalchemy import SQLAlchemy
from flask_login import (
    UserMixin,
    LoginManager
)

db = SQLAlchemy()
login_manager = LoginManager()
login_manager.session_protection = 'strong'
login_manager.login_view = 'main.login'
login_manager.login_message = "请登录，坏蛋。"
login_manager.login_message_category = "warning"

class User(UserMixin, db.Model):
    __tablename__ = 'users'

    id = db.Column(
        db.Integer,
        primary_key=True
    )
    username = db.Column(
        db.String(32),
        unique=True,
        nullable=False
    )# 用户名
    email = db.Column(
        db.String(64),
        unique=True,
        index=True,     # 加快查询
        nullable=False
    )# 用户电子邮箱
    password_hash = db.Column(
        db.String(128),
        nullable=False
    )# 密码的散列值 SHA256
    type = db.Column(
        db.Boolean(),
        nullable=False
    )# 管理员 True 普通账户 False

    @property
    def password(self):
        raise AttributeError('Cannot look password ^ ^')

    # 存储密码的哈希值
    @password.setter
    def password(self, password):
        self.password_hash = generate_password_hash(password)

    # 验证密码
    def verify_password(self, password):
        return check_password_hash(self.password_hash, password)

    @login_manager.user_loader
    def load_user(user_id):
        return User.query.get(int(user_id))

    def __init__(self, name, em, pw, t):
        self.username = name
        self.email = em
        self.password = pw
        self.type = t
        
    def __repr__(self):
        return '<User %r email %r>' % (self.username, self.email)

# 期刊 主编 多对多关系表
writing = db.Table(
    'writing',
    db.Column('journal_issn', db.String(9), db.ForeignKey('journals.issn')),
    db.Column('editor_name', db.String(16), db.ForeignKey('editors.name'))
)
# 期刊 主办单位 多对多关系表
management = db.Table(
    'management',
    db.Column('journal_issn', db.String(9), db.ForeignKey('journals.issn')),
    db.Column('organ_name', db.String(32), db.ForeignKey('organizers.name'))
)

class Journal(db.Model):
    __tablename__ = 'journals'

    issn = db.Column(
        db.String(9),
        primary_key=True
    )
    cn = db.Column(
        db.String(12),
        nullable=False,
        unique=True
    )
    cn_name = db.Column(
        db.String(128),
        nullable=False
    )
    en_name = db.Column(
        db.String(128),
        nullable=False
    )
    public_year = db.Column(
        db.SmallInteger,
        nullable=False
    )
    public_cycle = db.Column(
        db.SmallInteger,
        nullable=False
    )
    address = db.Column(
        db.String(128),
        nullable=False
    )
    zipcode = db.Column(
        db.String(6),
        nullable=False
    )
    tel = db.Column(
        db.String(32),
    )
    fax = db.Column(
        db.String(32)
    )
    # 告诉 Email 模型，你们可以通过 journal 找到我
    emails = db.relationship('Email', backref='journal')

    editors = db.relationship(
        'Editor',
        secondary=writing,
        lazy='dynamic',
        backref=db.backref('journals', lazy='dynamic')
    )

    organizers = db.relationship(
        'Organizer',
        secondary=management,
        lazy='dynamic',
        backref=db.backref('journals', lazy='dynamic')
    )

    def __init__(self, issn, cn, cn_name, en_name, year, cycle, addr, zipcode, tel=None, fax=None):
        self.issn = issn
        self.cn = cn
        self.cn_name = cn_name
        self.en_name = en_name
        self.public_year = year
        self.public_cycle = cycle
        self.address = addr
        self.zipcode = zipcode
        self.tel = tel
        self.fax = fax
        
    def __repr__(self):
        return '<Journal: %r issn %r>' % (self.cn_name, self.issn)

class Email(db.Model):
    __tablename__ = 'emails'
    email = db.Column(
        db.String(64),
        primary_key=True
    )
    # 当 Email 访问 journal 时，得到的就是其 ISSN
    to_issn = db.Column(
        db.String(9),
        db.ForeignKey('journals.issn')
    )

    def __init__(self, email, journal):
        self.email = email
        self.journal = journal
    
    def __repr__(self):
        return '<JournalISSN %r | Email %r' % (self.journal, self.email)

class Editor(db.Model):
    __tablename__ = 'editors'
    id = db.Column(
        db.Integer,
        primary_key=True
    )
    name = db.Column(
        db.String(16),
        unique=True,
        nullable=False
    )

    def __init__(self, name):
        self.name = name

    def __repr__(self):
        return '<Editor %r | Journals %r>' % (self.name, self.journals)

class Organizer(db.Model):
    __tablename__ = 'organizers'
    id = db.Column(
        db.Integer,
        primary_key=True
    )
    name = db.Column(
        db.String(32),
        unique=True,
        nullable=False
    )

    def __init__(self, name):
        self.name = name

    def __repr__(self):
        return '<Organ %r | Journals %r' % (self.name, self.journals)
