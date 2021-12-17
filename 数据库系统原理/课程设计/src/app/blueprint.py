from flask import (
    Blueprint,
    flash,
    redirect,
    url_for,
    render_template,
    request,
    send_file
)
from flask_login import (
    login_required,
    login_user,
    logout_user,
    current_user
)
from datetime import datetime
from .forms import (
    LoginForm,
    RegisterForm,
    JournalForm
)
from .models import (
    db,
    User,
    Journal,
    Email,
    Editor,
    Organizer,
    writing,
    management
)
# 创建名为 main 的蓝本
main = Blueprint('main', __name__)

### 开始定义路由

#################### 认证部分 ####################
@main.route('/login', methods=['GET', 'POST'])
def login():
    form = LoginForm()
    # POST
    if form.validate_on_submit():
        # 检查邮箱
        user = User.query.filter_by(email=form.email.data).first()
        # 检查密码
        if user is not None and user.verify_password(form.passwd.data):
            # 登录成功
            login_user(user)
            return redirect(url_for('main.index'))
        else:
            # 登录失败
            flash('无效的用户名或密码！', 'danger')
            return redirect(url_for('main.login'))
    # GET
    logout_user()   # 先登出用户，无论如何
    return render_template('login.html', form=form)

@main.route('/register', methods=['GET', 'POST'])
def register():
    form = RegisterForm()
    # POST
    if form.validate_on_submit():
        # 构造新 User 对象
        new_user = User(
            name=form.username.data,
            em=form.email.data,
            pw=form.passwd.data,
            t=False
        )
        # 插入 users 表中
        db.session.add(new_user)
        db.session.commit()
        flash('注册成功！您可以登录啦！', 'success')
        return redirect(url_for('main.login'))
    # GET
    return render_template('register.html',form=form)
####################  分割线  ####################

#################### 主体部分 ####################

# 主界面
@main.route('/index')
@login_required
def index():
    # 获取数据库所有 journal 数据
    journals = Journal.query.all()
    username = current_user.username
    flash('目前期刊数: {}'.format(len(journals)), 'info')
    return render_template('index.html', journals=journals, username=username)

# 搜索功能路由
@main.route('/search', methods=['POST'])
@login_required
def search():
    # 获取 POST 数据
    option = request.form.get('option', None)
    found = request.form.get('search', '')
    # 检查输入栏是否为空
    if found is '':
        flash('输入栏为空!','info')
        return redirect(url_for('main.index'))
    else:
        start = datetime.now()  # 记录开始时间点
        # 根据 Option 查找与 found 模糊匹配的数据库
        if option == 'cn_name':
            found = Journal.cn_name.like('%{}%'.format(found))
            results = Journal.query.filter(found).all()
        elif option == 'issn':
            found = Journal.issn.like('{}%'.format(found))
            results = Journal.query.filter(found).all()
        elif option == 'cn':
            found = Journal.cn.like('{}%'.format(found))
            results = Journal.query.filter(found).all()
    end = datetime.now()  # 记录结束时间点
    msg = '查询用时: %.3fms' % ((end-start).total_seconds()*1000,)
    flash(msg,'success')
    # 渲染结果
    return render_template('sear_result.html', results=results)

# 增添期刊路由
@main.route('/insert', methods=['GET','POST'])
@login_required
def insert():
    journal_form = JournalForm()
    # 检查当前用户是否有权限
    if current_user.type == False:
        flash('此操作无权限对于当前用户。', 'danger')
        return redirect(url_for('main.index'))
    if journal_form.insert_submit.data and journal_form.validate():
        # 检查 issn/cn 是否重复
        sanity_check = []
        sanity_check.append(Journal.query.filter_by(issn=journal_form.issn.data).first())
        sanity_check.append(Journal.query.filter_by(cn=journal_form.cn.data).first())
        if sanity_check[0] is not None or sanity_check[1] is not None:
            flash('ISSN 或 CN 已存在数据库中！请仔细检查。', 'danger')
            return redirect(url_for('main.insert'))
        
        # 替换 '' 为 None
        if journal_form.tel.data == '':
            journal_form.tel.data = None
        if journal_form.fax.data == '':
            journal_form.fax.data = None 
        # 新建一个 Journal 对象
        insert_item = Journal(
            issn=journal_form.issn.data,
            cn=journal_form.cn.data,
            cn_name=journal_form.cn_name.data,
            en_name=journal_form.en_name.data,
            year=journal_form.public_year.data,
            cycle=journal_form.public_cycle.data,
            addr=journal_form.address.data,
            zipcode=journal_form.zipcode.data,
            tel=journal_form.tel.data,
            fax=journal_form.fax.data
        )
        # 解析 Emails/Editors/Organs 字段
        # 它们都是靠'/'来分割
        emails = journal_form.emails.data.split('/')
        editors = journal_form.editors.data.split('/')
        organs = journal_form.organizers.data.split('/')
        # 将这些信息与插入项关联
        for loop_item in emails:
            if loop_item == '': # 跳过空项
                continue
            if Email.query.filter_by(email=loop_item).first() is None:
                db.session.add(Email(loop_item, insert_item))
            else:
                flash('此邮箱已经存在，请仔细检查！', 'danger')
                return redirect(url_for('main.insert'))

        for loop_item in editors:
            if loop_item == '': # 跳过空项
                continue
            tmp = Editor.query.filter_by(name=loop_item).first()
            if tmp is None:     # 如果此前没出现过这个主编
                insert_item.editors.append(Editor(loop_item))
            else:
                tmp.journals.append(insert_item)

        for loop_item in organs:
            if loop_item == '': # 跳过空项
                continue
            tmp = Organizer.query.filter_by(name=loop_item).first()
            if tmp is None:     # 如果此前没出现过这个主办方
                insert_item.organizers.append(Organizer(loop_item))
            else:
                tmp.journals.append(insert_item)

        # 提交
        db.session.add(insert_item)
        db.session.commit()
        # 返回总览 并给出插入成功提示
        flash('期刊数据添加成功！', 'success')
        return redirect(url_for('main.index'))
    else:
        flash('1. *为必填项', 'info')
        flash('2. 电子邮箱/主编/主办单位多个时请用 / 隔开','info')
        return render_template('jour_form.html', form=journal_form)


# 删除期刊路由
@main.route('/delete/<issn>')
@login_required
def delete(issn):
    # 检查当前用户是否有权限
    if current_user.type == False:
        flash('此操作无权限对于当前用户。', 'danger')
        return redirect(url_for('main.index'))
    journal = Journal.query.filter_by(issn=issn).first()
    # 先删除所有依赖: Email/主编/主办单位
    for tmp in journal.emails:
        db.session.delete(tmp)
    for tmp in journal.editors:
        journal.editors.remove(tmp)
    for tmp in journal.organizers:
        journal.organizers.remove(tmp)
    # 先提交
    db.session.commit()
    # 再删掉他自己
    db.session.delete(journal)
    db.session.commit()
    flash('删除期刊 {} 成功！'.format(issn), 'success')
    return redirect(url_for('main.index'))

# 修改期刊路由
@main.route('/update/<issn>', methods=['GET','POST'])
@login_required
def update(issn):
    update_form = JournalForm()
    # 检查当前用户是否有权限
    if current_user.type == False:
        flash('此操作无权限对于当前用户。', 'danger')
        return redirect(url_for('main.index'))
    journal = Journal.query.filter_by(issn=issn).first()
    # POST 
    if update_form.insert_submit.data and update_form.validate():
        start = datetime.now()
        # 检查 issn/cn 是否重复
        sanity_check = []
        sanity_check.append(Journal.query.filter_by(issn=update_form.issn.data).first())
        sanity_check.append(Journal.query.filter_by(cn=update_form.cn.data).first())
        if sanity_check[0] is not None:
            if sanity_check[0].issn != journal.issn:
                flash('ISSN: {} 已存在数据库中！请仔细检查。'.format(journal.issn), 'danger')
                return redirect(url_for('main.insert'))
        if sanity_check[1] is not None:
            if sanity_check[1].cn != journal.cn:
                flash('CN: {} 已存在数据库中！请仔细检查。'.format(journal.cn), 'danger')
                return redirect(url_for('main.insert'))
        # 替换 '' 为 None
        if update_form.tel.data == '':
            update_form.tel.data = None
        if update_form.fax.data == '':
            update_form.fax.data = None 
        # 先删除之前的信息
        for tmp in journal.emails:
            db.session.delete(tmp)
        for tmp in journal.editors:
            journal.editors.remove(tmp)
        for tmp in journal.organizers:
            journal.organizers.remove(tmp)
        # 先提交删除 否则后面外键不统一
        db.session.commit()
        # 基本字段的修改
        journal.cn_name = update_form.cn_name.data
        journal.en_name = update_form.en_name.data
        journal.issn = update_form.issn.data
        journal.cn = update_form.cn.data
        journal.address = update_form.address.data
        journal.tel = update_form.tel.data
        journal.fax = update_form.fax.data
        journal.public_year = update_form.public_year.data
        journal.public_cycle = update_form.public_cycle.data
        journal.zipcode = update_form.zipcode.data
        # 一对多 多对多关系修改
        emails = update_form.emails.data.split('/')
        editors = update_form.editors.data.split('/')
        organs = update_form.organizers.data.split('/')
        
        for loop_item in emails:
            if loop_item == '': # 跳过空项
                continue
            if Email.query.filter_by(email=loop_item).first() is None:
                db.session.add(Email(loop_item, journal))
            else:
                flash('此邮箱已经存在，请仔细检查！', 'danger')
                return redirect(url_for('main.insert'))

        for loop_item in editors:
            if loop_item == '': # 跳过空项
                continue
            tmp = Editor.query.filter_by(name=loop_item).first()
            if tmp is None:     # 如果此前没出现过这个主编
                journal.editors.append(Editor(loop_item))
            else:
                tmp.journals.append(journal)

        for loop_item in organs:
            if loop_item == '': # 跳过空项
                continue
            tmp = Organizer.query.filter_by(name=loop_item).first()
            if tmp is None:     # 如果此前没出现过这个主办方
                journal.organizers.append(Organizer(loop_item))
            else:
                tmp.journals.append(journal)
        # 提交
        db.session.commit()
        # 返回总览 并给出插入成功提示
        end = datetime.now()
        msg = '修改用时: %.3fms' % ((end-start).total_seconds()*1000,)
        flash('期刊信息修改成功！' + msg, 'success')
        return redirect(url_for('main.index'))
    # GET 自动填充原先字段
    update_form.cn_name.data = journal.cn_name
    update_form.en_name.data = journal.en_name
    update_form.issn.data = journal.issn
    update_form.cn.data = journal.cn
    update_form.public_year.data = journal.public_year
    update_form.public_cycle.data = journal.public_cycle
    update_form.address.data = journal.address
    update_form.zipcode.data = journal.zipcode
    update_form.tel.data = journal.tel
    update_form.fax.data = journal.fax
    # Email/主编/主办单位的填充稍微麻烦些
    padding = ''
    for tmp in journal.emails:
        padding = padding + tmp.email + '/'
    update_form.emails.data = padding[:-1] # 丢弃末尾 '/'
    padding = ''
    for tmp in journal.editors:
        padding = padding + tmp.name + '/'
    update_form.editors.data = padding[:-1] # 丢弃末尾 '/'
    padding = ''
    for tmp in journal.organizers:
        padding = padding + tmp.name + '/'
    update_form.organizers.data = padding[:-1] # 丢弃末尾 '/'
    flash('1. *为必填项', 'info')
    flash('2. 电子邮箱/主编/主办单位多个时请用 / 隔开','info')
    return render_template('jour_form.html', form=update_form)
    

# 期刊详细信息路由
@main.route('/detail/<issn>')
@login_required
def detail(issn):
    # 获取对应 issn 的期刊所有信息
    journal = Journal.query.filter_by(issn=issn).one()
    return render_template('journal_detail.html', journal=journal)

# 返回报表PDF路由
@main.route('/pdf')
@login_required
def pdf():
    return send_file('../report.pdf')

# 打印报表视图
@main.route('/print_report')
@login_required
def print_report():
    return render_template('print_report.html')

# 报表视图 请勿添加 login_required
# 否则 electron 打不开页面
@main.route('/use_for_reporting')
def report_table():
    journals = Journal.query.all()
    return render_template('report.html', journals=journals)
####################  分割线  ####################


## 关于作者 彩蛋
@main.route('/about')
@login_required
def about():
    return render_template('about.html')