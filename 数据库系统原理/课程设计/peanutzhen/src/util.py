############ 一些有用的工具 ###############
import json
import re
from tika import parser
from os.path import exists

from app.models import (
    User,
    Journal,
    Email,
    Editor,
    Organizer
)

def extract_example_dataset():
    """
     提取 2008中国百种学术期刊pdf 中的各个期刊内容
     并保存至 list ，里面的每个dict即为期刊内容
     并以 json 格式永久存储在磁盘
    """
    ## 解析 pdf 获取 text 内容，并保存
    # 当且仅当不存在时，否则每次运行都要内啥，很久
    if not exists('raw_dataset'):
        raw_text = parser.from_file('dataset.pdf')
        with open('raw_dataset', 'w') as f:
            f.write(raw_text['content'])
    
    ## 解析 raw_dataset 生成 json
    saver = []
    with open('raw_dataset', 'r') as f:
        raw = f.read()
        # 用 # 分割每个字段
        raw = re.sub(r'\n+', '#', raw)
        dataset = re.findall(r'期刊名称.*?创刊时间: [0-9]{4}', raw)
        for data in dataset:
            tmp_dict = dict()
            # 填充过滤得到的信息
            tmp_dict['期刊名称'] = re.search(r'期刊名称: (.*?)#', data).group(1)
            tmp_dict['英文刊名'] = re.search(r'英文刊名: (.*?)#', data).group(1)
            tmp_dict['cn'] = re.search(r'CN: (.*?)ISSN', data).group(1)
            tmp_dict['issn'] = re.search(r'ISSN: (.*?)#', data).group(1)
            tmp_dict['主编'] = re.search(r'主编: (.*?)#', data).group(1)
            tmp_dict['主办单位'] = re.search(r'主办单位: (.*?)#', data).group(1)
            tmp_dict['地址'] = re.search(r'地址: (.*?)#', data).group(1)
            tmp_dict['邮编'] = re.search(r'邮编: (.*?)#', data).group(1)
            tmp_dict['出版周期'] = re.search(r'出版周期\(期/年\): (.*?)创刊时间', data).group(1)
            tmp_dict['创刊时间'] = re.search(r'创刊时间: ([0-9]{4})', data).group(1)
            # 可空项特殊处理
            try:
                tmp_dict['电子信箱'] = re.search(r'电子信箱: (.*?)#', data).group(1)
            except AttributeError:
                tmp_dict['电子信箱'] = None
            try:
                tmp_dict['电话'] = re.search(r'电话: (.*?) 传真', data).group(1)
            except AttributeError:
                try:
                    tmp_dict['电话'] = re.search(r'电话: (.*?)#', data).group(1)
                except AttributeError:
                    tmp_dict['电话'] = None
            try:
                tmp_dict['传真'] = re.search(r'传真: (.*?)#', data).group(1)
            except AttributeError:
                tmp_dict['传真'] = None
            # 保存至 Saver
            saver.append(tmp_dict)

    # 保存至json格式
    with open('dataset.json', 'w') as f:
        json.dump(saver, f)
    
    # 返回解析列表
    return saver

def create_admin(app, db):
    """
    创建 管理员 账户
    """
    with app.app_context():
        db.session.add(
            User(
                'admin_zls',
                'astzls213@gmail.com',
                'iamadmin',
                True
            )
        )
        db.session.commit()

def add_journal(app, db, journal):
    """
    添加一个期刊信息to数据库
    """
    # 解析 journal 并填充
    aJournal = Journal(
        journal['issn'],
        journal['cn'],
        journal['期刊名称'],
        journal['英文刊名'],
        journal['创刊时间'],
        journal['出版周期'],
        journal['地址'],
        journal['邮编'],
        journal['电话'],
        journal['传真']
    )
    with app.app_context():
        db.session.add(aJournal)
        # 添加 电邮
        if journal['电子信箱'] is not None:
            for email_addr in re.split(r'[;,/ ]+', journal['电子信箱']):
                db.session.add(Email(email_addr, aJournal))
        # 添加主编
        for editor_name in re.split(r'[;,/ ]+', journal['主编']):
            tmp = Editor.query.filter_by(name=editor_name).first()
            if tmp is None:     # 如果此前没出现过这个主编
                aJournal.editors.append(Editor(editor_name))
            else:
                tmp.journals.append(aJournal)

        # 添加主办方
        for organ_name in re.split(r'[;,/ ]+', journal['主办单位']):
            tmp = Organizer.query.filter_by(name=organ_name).first()
            if tmp is None:     # 如果此前没出现过这个主编
                aJournal.organizers.append(Organizer(organ_name))
            else:
                tmp.journals.append(aJournal)
        
        db.session.commit()

