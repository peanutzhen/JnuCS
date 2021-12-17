from flask_wtf import FlaskForm
from datetime import datetime
from wtforms import (
    StringField,
    PasswordField,
    SubmitField,
    SelectField,
    IntegerField,
    ValidationError
)
from wtforms.validators import (
    Required,
    Email,
    Length,
    EqualTo,
    Regexp,
    NumberRange
)
from .models import (
    User
)


# 登录表单
class LoginForm(FlaskForm):
    email = StringField(
        label='电邮',
        render_kw={
            "placeholder": "you@example.com"
        },
        validators=[
            Required(),
            Length(1,64),
            Email()
        ]
    )
    passwd = PasswordField(
        label='密码',
        validators=[
            Required()
        ]
    )
    login = SubmitField('登录')

# 注册表单
class RegisterForm(FlaskForm):
    username = StringField(
        label='用户名',
        validators=[
            Required(),
            Length(1,32),
            Regexp(
                '^[A-Za-z][A-Za-z0-9_]*$',
                0,
                '用户名只能字母开头且只包含字母数字及下划线'
            )
        ]
    )
    email = StringField(
        label='电邮',
        render_kw={
            "placeholder": "you@example.com"
        },
        validators=[
            Email(),
            Required(),
            Length(1,64)
        ]
    )
    passwd = PasswordField(
        label='密码',
        validators=[
            Required(),
            EqualTo('passwd2', message='两次密码不相同')
        ]
    )
    passwd2 = PasswordField(
        label='确认密码',
        validators=[Required()]
    )
    submit = SubmitField('确认')
    # 定义内联检测函数
    def validate_email(self, field):
        if User.query.filter_by(email=field.data).first():
            raise ValidationError('电邮已被注册。')

    def validate_username(self, field):
        if User.query.filter_by(username=field.data).first():
            raise ValidationError('用户名已被注册。')

# 期刊表单
class JournalForm(FlaskForm):
    cn_name = StringField(
        label='中文刊名*',
        validators=[
            Required('不能为空哦'),
            Length(1,128)
        ]
    )
    en_name = StringField(
        label='英文刊名*',
        validators=[
            Required('不能为空哦'),
            Length(1,128)
        ]
    )
    issn = StringField(
        label='ISSN*',
        validators=[
            Required(),
            Length(1,9),
            Regexp(
                '^[0-9]{4}-[0-9]{3}[0-9xX]$',
                0,
                '无效的ISSN号,比如:0366-2341 '
            )
        ]
    )
    cn = StringField(
        label='CN*',
        validators=[
            Required(),
            Length(1,12),
            Regexp(
                '^[0-9]{2}-[0-9]{4}/[A-Z][A-Z0-9]?$',
                0,
                '请输入有效的CN号,比如:31-1339/TN'
            )
        ]
    )
    organizers = StringField(
        label='主办单位*',
        validators=[Required('不能为空哦')]
    )
    editors = StringField(
        label='主编*',
        validators=[Required('不能为空哦')]
    )
    public_year = IntegerField(
        label='创刊时间*',
        validators=[
            Required('请输入有效数字'),
            NumberRange(1800,datetime.now().year,'有效范围为1800至今')
        ]
    )
    public_cycle = IntegerField(
        label='出版周期(期/年)*',
        validators=[
            Required('请输入有效数字'),
            NumberRange(1,48,'有效范围1~48')
        ]
    )
    address = StringField(
        label='地址*',
        validators=[
            Required('不能为空哦'),
            Length(1,128)
        ]
    )
    zipcode = StringField(
        label='邮政编码*',
        validators=[
            Required(),
            Regexp(
                '^[0-9]{6}$',
                0,
                '请输入有效邮编,比如:100710'
            )
        ]
    )
    emails = StringField(
        label='电子邮箱',
        validators=[
            Length(0,128)
        ]
    )
    tel = StringField(
        label='电话',
        validators=[
            Length(0,32)
        ]
    )
    fax = StringField(
        label='传真',
        validators=[
            Length(0,32)
        ]
    )
    insert_submit = SubmitField('提交')
