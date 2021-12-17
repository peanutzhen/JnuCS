import json
import matplotlib.pyplot as plt

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

dirstrib = None
with open('/Users/astzls/Downloads/entries/\
flower-tpu/data/class-distrib/offi-oxford-dataset.json','r') as f:
    distrib = json.load(f)

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
           'trumpet creeper',  'blackberry lily',           'common tulip',     'wild rose']   

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

show_distrib(distrib)



    