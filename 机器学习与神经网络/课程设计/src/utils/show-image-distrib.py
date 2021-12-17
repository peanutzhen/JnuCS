import matplotlib.pyplot as plt
import json
from vgg import get_training_dataset

x=[0.00024652277352288365,0.00023268435325007886, 0.00012932042591273785,0.0001649513142183423,
5.306808088789694e-05,
6.63239843561314e-05,
0.00017125281738117337,
0.00010094221215695143,
0.0002154039975721389]
y=[0.66,0.71,0.72,0.73,0.74,0.75,0.75,0.75,0.76]

plt.figure(dpi=150)
for i in range(15):
    plt.subplot(3,5,i+1)
    plt.xticks([])
    plt.ylim([0,1])
    if i%5==0:
        plt.yticks([x/10.0 for x in range(11) if x%2 == 0])
    else:
        plt.yticks([])
    if i%5==0:
        plt.ylabel('val_acc')
    plt.plot(x,y,'bo',color='green')

plt.show()

def image_distribution(dataset):
    #define counting array
    classes = [x for x in range(104)]
    distrib = [0 for _ in range(104)]
    it = iter(dataset)
    for images,labels in it:
        labels = labels.numpy()
        for label in labels:
            distrib[label] += 1

    #save to file, use next time easily
    with open('classes_distribution.json','w') as f:
        json.dump(distrib,f)
    
    plt.bar(classes,distrib)
    plt.xlabel('CLASSES')
    plt.ylabel('Numbers')
    plt.title('Image numbers per class')
    plt.savefig('Image_Distribution.jpeg')
    plt.show()

# 调用前注意，要将get_training_dataset的repeat和数据增强关掉，加快绘画速度，否则死循环
#image_distribution(get_training_dataset())