import numpy as np
import sys


input = 'output.sys'
score = 'output.score'
beamsize = sys.argv[1]
encktnum = sys.argv[2]


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
score = np.sum(score, axis=0)
lines_id = np.transpose(lines_id.reshape(encktnum, -1)).reshape(-1, beamsize * encktnum )
score = np.transpose(score.reshape(encktnum, -1)).reshape(-1, beamsize * encktnum )

win_place = score.argmax(axis=1).tolist()
win_id = []
for i, j in enumerate(win_place):
    win_id.append(int(lines_id[i,j]))
win_lines = [all_lines[i] + '\n'  for i in win_id]

open('output.tok', "w", encoding="utf8").writelines(win_lines)
