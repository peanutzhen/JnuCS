#导入核心库
import tensorflow as tf
import numpy as np
import matplotlib.pyplot as plt
import json

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
BATCH_SIZE = 16 * strategy.num_replicas_in_sync # 根据cpu/tpu自动调整batch大小
lb = 0.00017125281738117337 #low bound
hb = 0.00023268435325007886 #high bound
lr_set = [np.random.uniform(lb,hb) for _ in range(9)] # 9个不同的学习率
EPOCHS = 6 # 训练周次
STEPS_PER_EPOCH = 12753 // BATCH_SIZE
IMAGE_SIZE = [512,512] #手动修改此处图像大小，进行训练
WIDTH = IMAGE_SIZE[0]
HEIGHT = IMAGE_SIZE[1]
CHANNELS = 3

CLASS_WEIGHT_TPU_VER2 = [0, 2.879, 1, 30.117, 2, 39.152, 3, 37.287, 4, 1.114, 5, 9.0, 6, 43.502, 7, 7.457, 8, 9.0, 9, 9.322, 
    10, 5.758, 11, 18.21, 12, 8.511, 13, 2.977, 14, 3.449, 15, 37.287, 16, 14.237, 17, 15.661, 18, 8.7, 19, 30.117, 
    20, 41.212, 21, 8.157, 22, 16.313, 23, 41.212, 24, 9.212, 25, 9.434, 26, 37.287, 27, 23.03, 28, 6.58, 29, 7.184, 
    30, 7.457, 31, 32.626, 32, 34.045, 33, 39.152, 34, 43.502, 35, 21.751, 36, 13.737, 37, 30.117, 38, 41.212, 39, 10.726, 
    40, 12.235, 41, 8.157, 42, 12.429, 43, 7.118, 44, 43.502, 45, 4.553, 46, 6.264, 47, 3.0, 48, 1.856, 49, 1.391, 
    50, 3.896, 51, 7.457, 52, 6.809, 53, 1.702, 54, 21.163, 55, 13.501, 56, 8.798, 57, 12.429, 58, 21.751, 59, 13.501, 
    60, 29.001, 61, 27.001, 62, 8.42, 63, 27.966, 64, 14.237, 65, 23.728, 66, 37.287, 67, 1.001, 68, 3.012, 69, 8.33, 
    70, 7.529, 71, 5.716, 72, 4.689, 73, 1.702, 74, 6.264, 75, 2.559, 76, 6.58, 77, 5.633, 78, 9.105, 79, 6.636, 
    80, 5.118, 81, 7.753, 82, 5.844, 83, 6.991, 84, 25.259, 85, 27.001, 86, 6.525, 87, 5.363, 88, 8.157, 89, 17.022, 
    90, 7.387, 91, 7.054, 92, 32.626, 93, 5.633, 94, 5.977, 95, 6.166, 96, 7.83, 97, 19.098, 98, 23.03, 99, 32.626, 
    100, 25.259, 101, 31.321, 102, 2.008, 103, 1.054
]# Ver2 using factor * frequency

#文件路径构造
try: #Running in Kaggle kernel
    from kaggle_datasets import KaggleDatasets
    BASE = KaggleDatasets().get_gcs_path('flower-classification-with-tpus')
except ModuleNotFoundError: # Running at my mac
    BASE = "/Users/astzls/Downloads/flower"

PATH_SELECT = { # 根据图像大小选择路径
    192: BASE + '/tfrecords-jpeg-192x192',
    224: BASE + '/tfrecords-jpeg-224x224',
    331: BASE + '/tfrecords-jpeg-331x331',
    512: BASE + '/tfrecords-jpeg-512x512'
}
IMAGE_PATH = PATH_SELECT[IMAGE_SIZE[0]]

#此处利用tf.io的库函数
#读出文件集方式很多种，也可以用os+re库进行
TRAINING_FILENAMES = tf.io.gfile.glob(IMAGE_PATH + '/train/*.tfrec')
VALIDATION_FILENAMES = tf.io.gfile.glob(IMAGE_PATH + '/val/*.tfrec')
TEST_FILENAMES = tf.io.gfile.glob(IMAGE_PATH + '/test/*.tfrec')


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
    # 还有下列api进行更无聊的处理
    #'random_brightness',  亮度
    # 'random_contrast', 对比度
    # 'random_crop',  这个就比较nb了，删掉图像中无用部分。。
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




def VGG_via_FC(lr):
    with strategy.scope():
        conv_base = tf.keras.applications.VGG16(weights='imagenet', 
                                                include_top=False,
                                                input_shape=[*IMAGE_SIZE, 3])
        conv_base.trainable = True # False = transfer learning, True = fine-tuning
        #冻结前3个block，解冻后面对block
        set_trainable = False
        for layer in conv_base.layers:
            if layer.name == 'block4_conv1':
                set_trainable = True
            if set_trainable:
                layer.trainable = True
            else:
                layer.trainable = False
        
        #conv_base.summary()
        model = tf.keras.Sequential([
            conv_base,
            tf.keras.layers.GlobalAveragePooling2D(),
            tf.keras.layers.Dense(104, activation='softmax')
        ])
    
    model.compile(
        optimizer=tf.keras.optimizers.Adam(lr=lr),
        loss = 'sparse_categorical_crossentropy',
        metrics=['sparse_categorical_accuracy']
    )
    return model

def train(model):
    history = model.fit(get_training_dataset(),  #给出训练数据(已经批处理了，且打乱了)
                        steps_per_epoch=STEPS_PER_EPOCH, #每个epoch所要重复获取数据然后训练的次数
                        epochs=6,           #训练次数
                        validation_data=get_validation_dataset(),  #使用验证集检查过拟合！
                        class_weight=CLASS_WEIGHT_TPU_VER2,
                        verbose=0
                        )
    rtv = dict()
    rtv['lr'] = tf.keras.backend.eval(model.optimizer.lr)
    acc = history.history['sparse_categorical_accuracy']
    val_acc = history.history['val_sparse_categorical_accuracy']

    max = np.max(val_acc)
    rtv['acc'] = acc
    rtv['val_acc'] = val_acc
    rtv['max'] = max
    return rtv
    
def show_and_log(values):
    values = sorted(values,key=lambda value: value['max'])
    message = 'Hyperparameter optimal\nlr scope:{} ~ {}\n'.format(lb,hb)
    # write it to log.txt
    with open('log.txt','w') as f:
        f.write(message)
        for i in range(1,len(values)+1):
            msg = 'Model{} (val_acc: {:.2f}) | lr: {}\n'.format(i,values[i-1]['max'],values[i-1]['lr'])
            f.write(msg)
        
    # plot figure
    plt.figure(dpi=150)
    epochs = range(1,len(values[0]['acc'])+1)
    for index,value in enumerate(values):
        plt.subplot(3,3,index+1)
        plt.plot(epochs,value['acc'],'--',label='t_acc',color='darkblue')
        plt.plot(epochs,value['val_acc'],'b',label='v_acc',color='green')
        plt.ylim(0,1)
        plt.legend()

    plt.savefig('model_proformance.jpeg')

    plt.figure(dpi=150)
    lr_x = [val['lr'] for val in values]
    acc_y = [val['max'] for val in values]
    plt.plot(lr_x,acc_y,'bo',color='green')
    plt.xlabel('lr')
    plt.ylabel('val_acc')
    plt.title('Distribution of lr')
    plt.savefig('distrib_lr.jpeg')
    plt.show()

# output saver
output = []
# 循环使用随机产生的lr进行训练
for lr in lr_set:
    model = VGG_via_FC(lr)
    output.append(train(model))
    print('lr: {} completed!'.format(lr))

show_and_log(output)