import argparse
import glob
import os
import re
parser = argparse.ArgumentParser()
parser.add_argument('pair', type=str)
parser.add_argument('year', type=int)
parser.add_argument('bpetc', type=str)
parser.add_argument('dictdir', type=str)
parser.add_argument('cktdir', type=str)
parser.add_argument('-l', type=float, default=1.)
parser.add_argument('-b', type=int, default=5)
parser.add_argument('--r2l', action='store_true')
parser.add_argument('--num', type=int, default=10)
parser.add_argument('--epoch',action='store_true' )
args = parser.parse_args()
pair = args.pair
year = args.year
bpetc = args.bpetc
dictdir = args.dictdir
num = args.num
isepoch = args.epoch
cmd = 'bash testyear.sh {} {} {} {}'.format(pair, year, bpetc, dictdir)
cktdir = args.cktdir
assert os.path.isdir(cktdir)
lenpen =  args.l
beamsize = args.b
r2l = '--r2l' if args.r2l else ''
finalcmd = '{cmd} {cktpath} -b {beamsize} -l {lenpen} {r2l}'

ckts = glob.glob(os.path.join(cktdir, 'checkpoint_*_*.pt')) if not isepoch else glob.glob(os.path.join(cktdir, 'checkpoint*.pt'))
def ckt2iter(ckts):
    dict_ckt2iter = []
    for ckt in ckts:
        if not isepoch:
            iter = int(ckt.split('_')[-1][:-3])
            dict_ckt2iter.append((iter, ckt))
        else:
            match = re.match(os.path.join(cktdir, 'checkpoint\d+.pt'), ckt)
            if match:
                iter = int(match.group().split('checkpoint')[-1][:-3])
                dict_ckt2iter.append((iter, ckt))
    return dict_ckt2iter
def select(dict_ckt2iter):
    sorteddict = sorted(dict_ckt2iter, reverse=True)
    x = [x[1] for x in sorteddict]
    return x
dict_ckt2iter = ckt2iter(ckts)
ckts = select(dict_ckt2iter)[:num]
print(ckts)

for ckt in ckts:
    newcmd = finalcmd.format(cmd=cmd, cktpath = ckt, beamsize=beamsize, lenpen=lenpen, r2l=r2l)
    print(newcmd)
    os.system(newcmd)
