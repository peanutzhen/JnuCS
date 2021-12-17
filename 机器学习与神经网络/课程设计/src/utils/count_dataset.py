import re
from os import listdir
from numpy import sum
# 统计image数量
def count_data_items(filenames):
    n = [int(re.compile(r"-([0-9]*)\.").search(filename).group(1)) for filename in filenames]
    return sum(n)

base = '/Users/astzls/Downloads/Kaggle/flower-tpu/tfrecords-jpeg-224x224'
train_path = base + '/train'
val_path = base + '/val'
test_path = base + '/test'

if __name__ == "__main__":
    print('Total',count_data_items(listdir(train_path)),'in training dataset.')
    print('Total',count_data_items(listdir(val_path)),'in validation dataset.')
    print('Total',count_data_items(listdir(test_path)),'in test dataset.')