import matplotlib.pyplot as plt
from math import cos,pi,e
# 来自enet的两个lr调度函数
def lrfn(epoch): #用cos进行退火
    LR_START = 2.5e-4
    LR_MIN = 1e-5

    lr = cos(epoch*pi/18) * LR_START

    return lr if lr>LR_MIN else LR_MIN

def lrfn1(epoch): # 用sigmoid进行学习率退火
    lr_start = 2.5e-4
    lr_min = 1e-5

    lr = lr_start / (1 + e ** (epoch - 5))
    return lr if lr > lr_min else lr_min

def lrfn_vgg(epoch):
    LR_START = 0.0002154039975721389
    LR_MAX = 0.00002 * 8
    LR_MIN = 0.00012
    LR_RAMPUP_EPOCHS = 5
    LR_SUSTAIN_EPOCHS = 0
    LR_EXP_DECAY = 0.8
    
    if epoch < LR_RAMPUP_EPOCHS:
        #lr = (LR_MAX - LR_START) / LR_RAMPUP_EPOCHS * epoch + LR_START
        lr = 0.0002154039975721389
    #elif epoch < LR_RAMPUP_EPOCHS + LR_SUSTAIN_EPOCHS:
        #lr = LR_MAX
    else:
        lr =  2.55611732865311e-05 * LR_EXP_DECAY**(epoch - LR_RAMPUP_EPOCHS - LR_SUSTAIN_EPOCHS) + LR_MIN
    return lr

def reslr(epoch):
    opt_lr = 9.888029308058321e-05
    lr_min = 2e-6
    if epoch < 3:
        return opt_lr
    else:
        return lr_min

epochs = [x for x in range(15)]
cos = [lrfn(x) for x in epochs]
sigmoid = [lrfn1(x) for x in epochs]
vgg = [lrfn_vgg(x) for x in epochs]
res = [reslr(x) for x in epochs]
#plt.plot(epochs,cos,'b',label='Cos',color='blue')
#plt.plot(epochs,sigmoid,'b',label='Sigmoid',color='green')
plt.plot(epochs,res,'b',label='res',color='blue')
plt.xlabel('epochs')
plt.ylabel('lr')
#plt.title('Cos V.S. Sigmoid LR Scheduler')
plt.legend()
#plt.savefig('lr_scheduler.jpeg')
plt.show()
