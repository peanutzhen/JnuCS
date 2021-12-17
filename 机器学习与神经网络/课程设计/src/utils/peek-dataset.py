# 此脚本用于观看官方数据集等真实图片长什么样子
# 建议观看512x512等，清晰点,但我把512删掉了，保留了224，节省磁盘空间

import tensorflow as tf
import matplotlib.pyplot as plt # 画图
import numpy as np# 图片矩阵化

#文件路径构造, 替换成自己等路径和分辨率
REVOLUTION = [224,224,3]
BASE = '/Users/astzls/Downloads/KaggleDataset/flower-tpu/\
tfrecords-jpeg-%dx%d'%(REVOLUTION[0],REVOLUTION[1])
# 显示图片等张数
NUM = 5

TRAINING_FILENAMES = tf.io.gfile.glob(BASE + '/train/00*.tfrec')
VALIDATION_FILENAMES = tf.io.gfile.glob(BASE + '/val/00*.tfrec')
TEST_FILENAMES = tf.io.gfile.glob(BASE + '/test/00*.tfrec')

CLASSES = ['pink primrose',    'hard-leaved pocket orchid', 'canterbury bells', 'sweet pea',     'wild geranium',     'tiger lily',           'moon orchid',              'bird of paradise', 'monkshood',        'globe thistle',         # 00 - 09
           'snapdragon',       "colt's foot",               'king protea',      'spear thistle', 'yellow iris',       'globe-flower',         'purple coneflower',        'peruvian lily',    'balloon flower',   'giant white arum lily', # 10 - 19
           'fire lily',        'pincushion flower',         'fritillary',       'red ginger',    'grape hyacinth',    'corn poppy',           'prince of wales feathers', 'stemless gentian', 'artichoke',        'sweet william',         # 20 - 29
           'carnation',        'garden phlox',              'love in the mist', 'cosmos',        'alpine sea holly',  'ruby-lipped cattleya', 'cape flower',              'great masterwort', 'siam tulip',       'lenten rose',           # 30 - 39
           'barberton daisy',  'daffodil',                  'sword lily',       'poinsettia',    'bolero deep blue',  'wallflower',           'marigold',                 'buttercup',        'daisy',            'common dandelion',      # 40 - 49
           'petunia',          'wild pansy',                'primula',          'sunflower',     'lilac hibiscus',    'bishop of llandaff',   'gaura',                    'geranium',         'orange dahlia',    'pink-yellow dahlia',    # 50 - 59
           'cautleya spicata', 'japanese anemone',          'black-eyed susan', 'silverbush',    'californian poppy', 'osteospermum',         'spring crocus',            'iris',             'windflower',       'tree poppy',            # 60 - 69
           'gazania',          'azalea',                    'water lily',       'rose',          'thorn apple',       'morning glory',        'passion flower',           'lotus',            'toad lily',        'anthurium',             # 70 - 79
           'frangipani',       'clematis',                  'hibiscus',         'columbine',     'desert-rose',       'tree mallow',          'magnolia',                 'cyclamen ',        'watercress',       'canna lily',            # 80 - 89
           'hippeastrum ',     'bee balm',                  'pink quill',       'foxglove',      'bougainvillea',     'camellia',             'mallow',                   'mexican petunia',  'bromelia',         'blanket flower',        # 90 - 99
           'trumpet creeper',  'blackberry lily',           'common tulip',     'wild rose'
           ]

def get_training_dataset():
    dataset = load_dataset(TRAINING_FILENAMES, labeled=True)
    dataset = dataset.shuffle(300)
    dataset = dataset.batch(NUM)
    return dataset

def get_validation_dataset():
    dataset = load_dataset(VALIDATION_FILENAMES, labeled=True)
    dataset = dataset.batch(NUM)
    return dataset

def get_test_dataset():
    dataset = load_dataset(TEST_FILENAMES, labeled=False)
    dataset = dataset.batch(NUM)
    return dataset


def load_dataset(filenames, labeled=True, ordered=False):
    ignore_order = tf.data.Options()
    if not ordered:
        ignore_order.experimental_deterministic = False #详见help

    dataset = tf.data.TFRecordDataset(filenames)
    dataset = dataset.with_options(ignore_order)
    dataset = dataset.map(read_labeled_tfrecord if labeled
                     else read_unlabeled_tfrecord
                     )
    return dataset


def decode_image(image_data):
    image = tf.image.decode_jpeg(image_data, channels=3)
    image = tf.cast(image, tf.float32)
    image /= 255.0
    image = tf.reshape(image, REVOLUTION)
    return image

def read_labeled_tfrecord(example):
    FEATURE = {
        "image": tf.io.FixedLenFeature([], tf.string),
        "class": tf.io.FixedLenFeature([], tf.int64)
    }
    example = tf.io.parse_single_example(example, FEATURE)
    image = decode_image(example['image'])
    label = tf.cast(example['class'], tf.int32)
    return image, label

def read_unlabeled_tfrecord(example):
    FEATURE = {
        "image": tf.io.FixedLenFeature([], tf.string), 
        "id": tf.io.FixedLenFeature([], tf.string)
    }
    example = tf.io.parse_single_example(example, FEATURE)
    image = decode_image(example['image'])
    idnum = example['id']
    return image, idnum

# peek at 训练集
train_dataset = next(iter(get_training_dataset()))
# peek at 验证集
valid_dataset = next(iter(get_validation_dataset()))
# peek at 测试集
test_dataset = next(iter(get_test_dataset()))

def show_batch_images(batch_images,name):
    images, labels = batch_images
    labels = labels.numpy()
    # 开始绘图
    fig = plt.figure()
    fig.suptitle(name)
    
    for i, image in enumerate(images):
        image = image.numpy()
        ax = fig.add_subplot(1,NUM,i+1)
        if type(labels[i]) == np.int32:
            ax.title.set_text(CLASSES[labels[i]])
        else:
            ax.title.set_text(labels[i])
        ax.axis('off')
        ax.imshow(image)

    fig.tight_layout()
    fig.savefig(name+'.jpg')
    plt.show()


show_batch_images(train_dataset,'train-dataset')
show_batch_images(valid_dataset,'valid-dataset')
show_batch_images(test_dataset,'test-dataset')