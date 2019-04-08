import argparse
import glob
import os
import re
parser = argparse.ArgumentParser()
parser.add_argument('pair', type=str)
parser.add_argument('year', type=int)
parser.add_argument('bpetc', type=str)
parser.add_argument('cktdir', type=str)
args = parser.parse_args()
pair = args.pair
year = args.year
bpetc = args.bpetc
isepoch = True
cmd = 'bash inferyear.sh {} {} {} '.format(pair, year, bpetc, )
cktdir = args.cktdir
assert os.path.isdir(cktdir)

finalcmd = '{cmd} {cktpath} '

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
ckts = select(dict_ckt2iter)
print(ckts)

for ckt in ckts:
    newcmd = finalcmd.format(cmd=cmd, cktpath = ckt, )
    print(newcmd)
    os.system(newcmd)
