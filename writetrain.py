import io
import os
import sys
args = r'''HOME=/blob/v-jinhzh/code/fairseq_baseline
cd $HOME

python -c "import torch; print(torch.__version__)"
export CUDA_VISIBLE_DEVICES=0,1,2,3
nvidia-smi

DATA={data}
ARCH=transformer_vaswani_wmt_en_de_big
SAVE=checkpoints/{save}
if [ ! -d $SAVE ]
then
    mkdir -p $SAVE
    cp {model} $SAVE/checkpoint_last.pt
fi



python -m torch.distributed.launch --nproc_per_node 4  train.py $DATA \
  --arch $ARCH  --share-decoder-input-output-embed  \
  --optimizer adam --adam-betas '(0.9, 0.98)' --clip-norm 0.0 \
  --lr-scheduler inverse_sqrt --warmup-init-lr 1e-07 --warmup-updates 4000 \
  --lr 0.0005 --min-lr 1e-09 \
  --dropout 0.3 --weight-decay 0.0 --criterion label_smoothed_cross_entropy --label-smoothing 0.1 \
  --max-tokens 3084 \
  --save-dir $SAVE --update-freq 8  --seed 121 --ddp-backend=no_c10d

'''
data = sys.argv[1]
save = sys.argv[2]
model = sys.argv[3]
newargs = args.format(data=data, save=save, model=model)
fn = 'phillyscript/train_{save}.sh'.format(save=save)
print(newargs)
with io.open(fn, 'w', newline='\n') as tgt:
    tgt.write(newargs)
os.system('chmod 777 {}'.format(fn))