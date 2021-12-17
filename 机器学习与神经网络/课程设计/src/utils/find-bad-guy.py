!pip install -q efficientnet
# 此脚本旨在找出是哪个b最难识别，然后加大它的图片量，不出意外都是那些
# 数据比较少的
import tensorflow as tf
import efficientnet.tfkeras as efn 
import numpy as np
import matplotlib.pyplot as plt
import re
import json
import re

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


AUTO = tf.data.experimental.AUTOTUNE

BATCH_SIZE = 16 * strategy.num_replicas_in_sync # 根据cpu/tpu自动调整batch大小

IMAGE_SIZE = [512,512]
WIDTH = IMAGE_SIZE[0]
HEIGHT = IMAGE_SIZE[1]
CHANNELS = 3

# 加载官方数据集
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


VALIDATION_FILENAMES = tf.io.gfile.glob(IMAGE_PATH + '/val/*.tfrec')

# 统计image数量
def count_data_items(filenames):
    n = [int(re.compile(r"-([0-9]*)\.").search(filename).group(1)) for filename in filenames]
    return np.sum(n)

def get_validation_dataset(order=False):
    dataset = load_dataset(VALIDATION_FILENAMES, labeled=True,ordered=order)
    dataset = dataset.batch(BATCH_SIZE)
    dataset = dataset.cache()
    dataset = dataset.prefetch(AUTO) 
    return dataset

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

# 加载验证集
print('Preparing dataset...')
dataset = get_validation_dataset(order=True)
images = dataset.map(lambda image, label: image)
labels = dataset.map(lambda image, label: label).unbatch()
nums_valid_images = count_data_items(VALIDATION_FILENAMES)
# 加载模型

print('Model loading...')
model_path = '/kaggle/input/data95-8/95-8.h5'
model = tf.keras.models.load_model(model_path)

# 用验证集预测
print('Predicting...')
output = model.predict(images,verbose=1)
prediction = np.argmax(output,axis=-1)

correct_labels = next(iter(labels.batch(nums_valid_images))).numpy()

mistake = [0 for _ in range(104)] # 104 classes
print('Computing mistakes...')
for i in range(nums_valid_images):
    if prediction[i] != correct_labels[i]:
        mistake[correct_labels[i]]+=1

with open('mistake.json','w') as f:
    json.dump(mistake,f)

classes = [x for x in range(104)]
plt.bar(classes,mistake)
plt.xlabel('CLASSES')
plt.ylabel('Mistake count')
plt.title('Mistakes each class')
plt.savefig('mistake.jpeg')
plt.show()