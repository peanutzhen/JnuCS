#导入核心库
import tensorflow as tf
from tensorflow.keras.applications import ResNet101V2
import numpy as np
import matplotlib.pyplot as plt
import re
from math import cos,pi

try:
    #解析TPU芯片集群
    tpu = tf.distribute.cluster_resolver.TPUClusterResolver()
    #kaggle不需要喂参数，他默认好了
    tf.config.experimental_connect_to_cluster(tpu)
    # 配置运算器
    tf.tpu.experimental.initialize_tpu_system(tpu)
    # 初始化tpu系统
except ValueError: #本地运行，CPU
    tpu = None

#获得分配策略，进行优化，以提升训练速度
if tpu:
    strategy = tf.distribute.experimental.TPUStrategy(tpu)
else:
    strategy = tf.distribute.get_strategy()

#后面很多核心函数都有优化参数，根据性能自动选择
AUTO = tf.data.experimental.AUTOTUNE
#超参数定义
#strategy来自tpu_settings.py
BATCH_SIZE = 8 * strategy.num_replicas_in_sync # 根据cpu/tpu自动调整batch大小
LEARNING_RATE = 9.888029308058321e-05
EPOCHS = 8 # 训练周次


IMAGE_SIZE = [512,512] #手动修改此处图像大小，进行训练
WIDTH = IMAGE_SIZE[0]
HEIGHT = IMAGE_SIZE[1]
CHANNELS = 3

# 加载官方数据集
try: #Running in Kaggle kernel
    from kaggle_datasets import KaggleDatasets
    BASE = KaggleDatasets().get_gcs_path('flower-classification-with-tpus')
except ModuleNotFoundError: # 本地训练
    BASE = "替换成自己的路径"

IMAGE_PATH = BASE + '/tfrecords-jpeg-512x512'

#此处利用tf.io的库函数
#读出文件集方式很多种，也可以用os+re库进行
TRAINING_FILENAMES = tf.io.gfile.glob(IMAGE_PATH + '/train/*.tfrec')
VALIDATION_FILENAMES = tf.io.gfile.glob(IMAGE_PATH + '/val/*.tfrec')
TEST_FILENAMES = tf.io.gfile.glob(IMAGE_PATH + '/test/*.tfrec')

# 牛津大学花蕊数据（原：7310 数据清洗后：2718）Oxford 102 for TPU competition
# 使用后，精确度提升2%
try: #Running in Kaggle kernel
    from kaggle_datasets import KaggleDatasets
    ext = KaggleDatasets().get_gcs_path('oxford-102-for-tpu-competition')
except ModuleNotFoundError: # Running at my mac
    ext = None

ext_path = ext + '/tfrecords-jpeg-512x512'

TRAINING_FILENAMES += tf.io.gfile.glob(ext_path + '/*.tfrec')


# 统计image数量
def count_data_items(filenames):
    n = [int(re.compile(r"-([0-9]+)\.").search(filename).group(1)) for filename in filenames]
    return np.sum(n)

#下面是核心函数构造，自顶向下
def get_training_dataset():
    #严格遵循代码开头注释流程
    dataset = load_dataset(TRAINING_FILENAMES, labeled=True) #labeled参数是用来判断数据有没有label的，比如test dataset就没有label
    #装载分离好等数据，每个example含image，class等等，其中kaggle说image的图像是jpeg格式的
    dataset = dataset.map(data_augmentation, num_parallel_calls=AUTO)
    #进行数据扩容，此步非常重要！可大大提升训练精度，已被广泛使用，不用你就out了
    dataset = dataset.shuffle(2048)
    #打乱，2048是根据data的数量决定的。可以先写个函数跑跑究竟有多少图片可供训练
    dataset = dataset.batch(BATCH_SIZE)
    #批处理
    dataset = dataset.repeat()
    #repeat无参数说明无限重复dataset。放心，不会内存溢出，只是懒循环罢了
    dataset = dataset.prefetch(AUTO)
    #根据cpu决定是否提前准备数据。为什么要这么做？原因是我想采用tpu进行训练，那么在tpu在训练时，cpu可以预先把下一批图像load到内存，当
    # tpu训练好了，直接又能进行下一批当训练，减少了训练时间。
    # 还是那句话，不用，你就out了 
    return dataset

def get_validation_dataset():
    dataset = load_dataset(VALIDATION_FILENAMES, labeled=True)
    dataset = dataset.batch(BATCH_SIZE)
    dataset = dataset.cache() #cache dataset到memory，加速训练时间，只有3712张
    dataset = dataset.prefetch(AUTO) 
    return dataset

def get_test_dataset():
    dataset = load_dataset(TEST_FILENAMES, labeled=False)
    dataset = dataset.batch(BATCH_SIZE)
    #dataset = dataset.cache() #可cache也可以步cache，随便。但是有7382个测试图片，小心内存溢出
    dataset = dataset.prefetch(AUTO) 
    return dataset

#完善核心函数中的小函数
def load_dataset(filenames, labeled=True, ordered=False):
    #ordered参数是指并行读取数据时不必在意是否按照原来顺序，加快速度
    #顺序不重要的= =

    #不在意顺序预处理
    ignore_order = tf.data.Options()
    if not ordered:
        ignore_order.experimental_deterministic = False #详见help

    #利用API导入初始TFrec文件集数据
    dataset = tf.data.TFRecordDataset(filenames, num_parallel_reads=AUTO)
    #设置dataset，让他保持并行读出来的顺序就行了
    dataset = dataset.with_options(ignore_order)
    #根据label决定传入带标签的解析函数，还是不带标签（test只有id）的解析函数
    dataset = dataset.map(read_labeled_tfrecord if labeled
                     else read_unlabeled_tfrecord, 
                     num_parallel_calls=AUTO)
    return dataset #现在dataset的每个data有两个部分了，一个是image，一个是class或id号

def data_augmentation(image, label):
    #所谓数据扩容，就是把原来的照片左移或右移，或上下左右反转一下，就得到了“新”图像
    #此方法利用了现实世界的平移不变形和空间不变形

    #这里我用了随机上下左右翻转，应该够用了吧。。
    image = tf.image.random_flip_left_right(image)
    image = tf.image.random_flip_up_down(image)
    image = tf.image.random_saturation(image, lower=0, upper=3)

    # 还有下列api进行更无聊的处理
    #'random_brightness',  亮度
    # 'random_contrast', 对比度
    # 'random_crop', 缩放
    # 'random_flip_up_down', 上下翻转
    # 'random_hue', 色相
    # 'random_jpeg_quality',  图片质量
    # 'random_saturation' 饱和度
    return image, label   

def decode_image(image_data):
    #由于给的图像是jpeg格式，故用对应api进行处理。
    #为什么要decode，因为他把图片写成bytes串了
    image = tf.image.decode_jpeg(image_data, channels=3)
    #得到tf.Tensor形式的image
    image = tf.cast(image, tf.float32)
    image /= 255.0
    #将image的每个数值调整在[0,1]之间，方便训练
    image = tf.reshape(image, [*IMAGE_SIZE, 3])
    #reshape此部非常重要，调试的时候被坑了，老是说什么shape不匹配
    return image

def read_labeled_tfrecord(example):
    FEATURE = {
        "image": tf.io.FixedLenFeature([], tf.string),
        "class": tf.io.FixedLenFeature([], tf.int64)  
    }
    example = tf.io.parse_single_example(example, FEATURE)
    image = decode_image(example['image'])
    label = tf.cast(example['class'], tf.int32)
    return image, label #返回一个以 图像数组和标签形式的数据集

def read_unlabeled_tfrecord(example):
    FEATURE = {
        "image": tf.io.FixedLenFeature([], tf.string), 
        "id": tf.io.FixedLenFeature([], tf.string)
    }
    example = tf.io.parse_single_example(example, FEATURE)
    image = decode_image(example['image'])
    idnum = example['id']
    return image, idnum

def show_acc_loss(history):
    acc = history.history['sparse_categorical_accuracy']
    val_acc = history.history['val_sparse_categorical_accuracy']

    loss = history.history['loss']
    val_loss = history.history['val_loss']

    epochs = range(1,len(acc)+1)

    plt.plot(epochs,acc,'bo',label='Training acc')
    plt.plot(epochs,val_acc,'b',label='Validation acc')
    plt.xlabel('Epochs')
    plt.ylabel('Accuracy')
    plt.title('Accuracy: GAP | lr: {} | Adam '.format(LEARNING_RATE))
    plt.legend()
    plt.savefig('acc.jpg')

    plt.figure()

    plt.plot(epochs,loss,'bo',label='Training loss')
    plt.plot(epochs,val_loss,'b',label='Validation loss')
    plt.xlabel('Epochs')
    plt.ylabel('Loss & CE')
    plt.title('Loss: GAP | lr: {} | Adam '.format(LEARNING_RATE))
    plt.legend()

    plt.savefig('loss.jpg')

    plt.show()
    
#核心函数定义
def res():
    with strategy.scope():
        conv_base = ResNet101V2(weights='imagenet',
                                include_top=False ,
                                input_shape=[*IMAGE_SIZE, 3])
        conv_base.trainable = True

        set_trainable = False
        for layer in conv_base.layers:
            if layer.name == 'conv4_block22_preact_bn':
                set_trainable = True
            if set_trainable:
                layer.trainable = True
            else:
                layer.trainable = False

        input = tf.keras.layers.Input(shape=(512,512,3))  
        res = conv_base(input)
        gap = tf.keras.layers.GlobalAveragePooling2D()(res)
        dropout = tf.keras.layers.Dropout(0.25)(gap)
        output = tf.keras.layers.Dense(104, activation='softmax')(dropout)

        model = tf.keras.models.Model(input,output)

    model.compile(
        optimizer=tf.keras.optimizers.Adam(lr=LEARNING_RATE),
        loss = 'sparse_categorical_crossentropy',
        metrics=['sparse_categorical_accuracy']
    )
    return model

# 创建网络       
model = res()

# 设置回调函数，当验证loss不再下降2个epochs时，stopping
def lrfn(epoch):
    opt_lr = 9.888029308058321e-05
    lr_min = 2e-6
    factor = 2
    if epoch < 3:
        return opt_lr
    else:
        return lr_min


callbacks_list = [
    tf.keras.callbacks.EarlyStopping(
        monitor='val_loss',
        patience=2
    ),
    tf.keras.callbacks.LearningRateScheduler(
        lrfn,
        verbose=1
    )
]


#开 始 训 练 ?
if tpu:
    nums_image = count_data_items(TRAINING_FILENAMES)
    STEPS_PER_EPOCH = nums_image // BATCH_SIZE
    print('Total {} images will be training..'.format(nums_image))

    history = model.fit(get_training_dataset(),  #给出训练数据(已经批处理了，且打乱了)
                        steps_per_epoch=STEPS_PER_EPOCH, #每个epoch所要重复获取数据然后训练的次数
                        epochs=EPOCHS,           #训练次数
                        validation_data=get_validation_dataset(),  #使用验证集检查过拟合！
                        callbacks=callbacks_list,
                        verbose=2
                        )
    model.save('best.h5')

    show_acc_loss(history)

