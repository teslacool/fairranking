import io
import argparse
import os
# ' python generate.py /blob/v-jinhzh/data/wmt14_en_de_joined_dict_tian \
# --path checkpoints/wmt14ende_s2_warmup_resetlr_dropout_0.5/checkpoint132.pt \
# --batch-size 128 --beam 5 --remove-bpe --quiet'
parser = argparse.ArgumentParser()
parser.add_argument('path', type=str, )
parser.add_argument('--data', type=str, default='/blob/v-jinhzh/data/wmt14_en_de_joined_dict_tian')
parser.add_argument('--bsz', type=int, default=128)
parser.add_argument('--beam', type=int, default=5)

config = 'python generate.py {data} --path {path} --batch-size {bsz} --beam {beam}  --remove-bpe --quiet'
tgtfile = 'bleu.logs'
args = parser.parse_args()
path = args.path
data = args.data
bsz = args.bsz
beam = args.beam
tgtfile = os.path.join(path, tgtfile)
def find_all_ckt(path):
    fns = os.listdir(path)
    fn2order = {}
    for fn in fns:
        if fn[-4].isdigit():
            order = fn[10:][:-3]
            if order.startswith('_'):
                order = order[1:]
            fn2order[fn] = order
    newfns = sorted(fn2order.keys(), key= lambda  k: fn2order[k])
    # print(newfns)
    return newfns


def clean_ckts(fns):
    newfns = []
    if not os.path.exists(tgtfile):
        return fns
    else:
        lines = io.open(tgtfile, 'r', encoding='utf8', newline='\n').readlines()
        lines = [line.strip() for line in lines]
        for fn in fns:
            if fn not in lines:
                newfns.append(fn)
        return newfns

fns = find_all_ckt(path)
fns = clean_ckts(fns)
print(fns)
for fn in fns:
    cmd = config.format(data=data, path=os.path.join(path, fn), bsz=bsz, beam=beam)
    # print(cmd)
    cmd = '{} > {}'.format(cmd, os.path.join(path, 'infer.logs'))
    print(cmd)
    os.system(cmd)
    cmd = 'echo {} >> {}'.format(fn, tgtfile)
    print(cmd)
    os.system(cmd)
    cmd = "cat {} | grep '| Generate test with beam='  >> {}".format(os.path.join(path, 'infer.logs'), tgtfile)
    print(cmd)
    os.system(cmd)