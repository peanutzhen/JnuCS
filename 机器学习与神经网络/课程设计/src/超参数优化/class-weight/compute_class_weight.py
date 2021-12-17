import json
import numpy as np
import matplotlib.pyplot as plt
from math import log

with open('classes_distribution.json','r') as f:
    data = json.load(f)

def compute_class_wights(data,delta=0.0614):
    # 0.0614 is total_num devided by max_num(class), there is 12753 / 783 = 0.0614
    total_num = np.sum(data)
    class_weights = list()
    for index,num in enumerate(data):
        weight = delta * total_num / float(num)
        weight = round(weight,3) # 保留3位小数就好了
        # tpu need a flat list, instead of dict said in keras doc. 
        class_weights.append(index)
        class_weights.append(weight)
    
    return class_weights


def show_distrib(data):
    labels = ['(0,50)','[50,120)','[120,300)','[300,inf]']
    colors = ['red','yellow','green','gray']
    precent = [0 for _ in range(4)]
    for x in data:
        if x < 50:
            precent[0] += 1
        elif x < 120:
            precent[1] += 1
        elif x < 300:
            precent[2] += 1
        else:
            precent[3] += 1
    
    plt.pie(
        precent,
        labels=labels,
        colors=colors,
        shadow=True,
        autopct='%1.1f%%'
    )
    plt.legend()
    plt.title('Image num distribution')
    #save jpeg
    plt.savefig('num_distrib.jpeg')
    plt.show()

class_weights = compute_class_wights(data)
print(class_weights)
with open('class_weights.json','w') as f:
    json.dump(class_weights,f)
