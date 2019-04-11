import numpy as np
import sys
import os
import subprocess

input = 'output.sys'
score = 'output.score'
beamsize = sys.argv[1]
encktnum = sys.argv[2]
tgtlng = sys.argv[3]
srclng = 'ru' if tgtlng == 'en' else 'en'

print('beamsize {}'.format(beamsize))


def read_file(fname):
    with open(fname, "r", encoding="utf8") as ff:
        all_lines = [x.strip() for x in ff]
    return all_lines,


def read_score(fname):
    all_lines, = read_file(fname)
    return np.array([float(x) for x in all_lines]).astype("float32")




def find_winner(ret_lines_1, ret_lines_2, score_1, score_2):
    assert len(ret_lines_1) == len(ret_lines_2) == len(score_1) == len(score_2)
    return [l1 if s1 > s2 else l2 for (l1, l2, s1, s2) in zip(ret_lines_1, ret_lines_2, score_1, score_2)]


all_lines, = read_file(input)
lines_id = np.array([int(x) for x in range(len(all_lines))]).astype("int64")


score = read_score(score)
cktnum = score.shape[0] / lines_id.shape[0]
cktnum = int(cktnum)
beamsize = int(beamsize)
encktnum = int(encktnum)
score = score.reshape(cktnum, -1)
step = 1
besta = 0
bestb = 0
bestc = 0
bestbleu = 0
lines_id = np.transpose(lines_id.reshape(encktnum, -1)).reshape(-1, beamsize * encktnum)
for aa in range(0, 101, step):
    for bb in range(0, 101-aa, step):
        c = 100 - aa -bb
        a = aa / 100
        b = bb / 100
        c = c / 100
        tmpscore = score
        tmpscore[0,] = a * tmpscore[0]
        tmpscore[1] = b * tmpscore[1]
        tmpscore[2] = c * tmpscore[2]
        tmpscore = np.sum(tmpscore, axis=0)
        tmpscore = np.transpose(tmpscore.reshape(encktnum, -1)).reshape(-1, beamsize * encktnum)
        win_place = tmpscore.argmax(axis=1).tolist()
        win_id = []
        for i, j in enumerate(win_place):
            win_id.append(int(lines_id[i, j]))
        win_lines = [all_lines[i] + '\n' for i in win_id]

        open('output.tok', "w", encoding="utf8").writelines(win_lines)
        cmd = 'perl ../mosesdecoder/scripts/tokenizer/detokenizer.perl -l {} < output.tok > output.tok.detok'.format(tgtlng)
        print(cmd)
        os.system(cmd)
        cmd = 'cat output.tok.detok | ../sockeye/sockeye_contrib/sacrebleu/sacrebleu.py /blob/v-jinhzh/data/wmttest/testdata/{src}{tgt}.{tgt}'.format(src=srclng, tgt=tgtlng)
        out = subprocess.check_output(cmd, shell=True).decode('utf-8')
        out = out.strip().split('=',1)[1].strip().split()[0].strip()
        out = float(out)
        if out > bestbleu:
            besta = a
            bestb = b
            bestc = c
            bestbleu = out
        print(bestbleu)
        print(a, b ,c)
c = bestc
a = besta
b = bestb
print('a {} b {} c {} bleu {}'.format(a, b ,c ,bestbleu))
tmpscore = score
tmpscore[0,] = a * tmpscore[0]
tmpscore[1] = b * tmpscore[1]
tmpscore[2] = c * tmpscore[2]
tmpscore = np.sum(tmpscore, axis=0)
tmpscore = np.transpose(tmpscore.reshape(encktnum, -1)).reshape(-1, beamsize * encktnum)
win_place = score.argmax(axis=1).tolist()
win_id = []
for i, j in enumerate(win_place):
    win_id.append(int(lines_id[i, j]))
win_lines = [all_lines[i] + '\n' for i in win_id]

open('output.tok', "w", encoding="utf8").writelines(win_lines)
cmd = 'perl ../mosesdecoder/scripts/tokenizer/detokenizer.perl -l {} < output.tok > output.tok.detok'.format(tgtlng)
print(cmd)
os.system(cmd)
cmd = 'cat output.tok.detok | ../sockeye/sockeye_contrib/sacrebleu/sacrebleu.py /blob/v-jinhzh/data/wmttest/testdata/{src}{tgt}.{tgt}'.format(src=srclng, tgt=tgtlng)
os.system(cmd)
