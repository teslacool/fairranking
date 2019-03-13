import numpy as np
import sys
import os


ckt1 = sys.argv[1]
ckt2 = sys.argv[2]
lng = sys.argv[3]
year = sys.argv[4]
input_1 = ckt1 + '.output.sys'
input_2 = ckt2 + '.output.sys'
score_11 = ckt1 + '.output.{}'.format(0)
score_12 = ckt1 + '.output.{}'.format(1)
score_21 = ckt2 + '.output.{}'.format(1)
score_22 = ckt2 + '.output.{}'.format(0)

tmpF = ckt1 +'.result.alpha{}.gamma{}'



beamsize = 5
detokenize = 'perl /blob/v-jinhzh/code/mosesdecoder/scripts/tokenizer/detokenizer.perl -l {} < {} > {}'
sacrebleu = 'cat {} | /blob/v-jinhzh/code/sockeye/sockeye_contrib/sacrebleu/sacrebleu.py -t {} -l {}'


def read_file(fname):
    with open(fname, "r", encoding="utf8") as ff:
        all_lines = [x.strip() for x in ff]
    return all_lines, np.array([len(x.split()) for x in all_lines]).astype("float32")


def read_score(fname):
    all_lines, _ = read_file(fname)
    return np.array([float(x) for x in all_lines]).astype("float32")


def process_one_file(lines, cnt, S1, S2, alpha, gamma):
    SS = alpha * S1 + (1. - alpha) * S2
    SS = SS / (cnt + 1.) ** gamma
    SS = SS.reshape((-1, beamsize))
    idx_list = SS.argmax(axis=1).tolist()
    ret_lines, ret_scores = [], []
    for ii, idx in enumerate(idx_list):
        ret_lines.append(lines[ii * beamsize + idx])
        ret_scores.append(SS[ii, idx])

    return ret_lines, ret_scores


def find_winner(ret_lines_1, ret_lines_2, score_1, score_2):
    assert len(ret_lines_1) == len(ret_lines_2) == len(score_1) == len(score_2)
    return [l1 if s1 > s2 else l2 for (l1, l2, s1, s2) in zip(ret_lines_1, ret_lines_2, score_1, score_2)]


all_lines_1, cnt_1 = read_file(input_1)
all_lines_2, cnt_2 = read_file(input_2)

score_11 = read_score(score_11)
score_12 = read_score(score_12)

score_21 = read_score(score_21)
score_22 = read_score(score_22)

gamma = -0.

max_bin = 20

for aa in range(max_bin + 1):
    alpha = aa / max_bin
    alpha = 1. - alpha
    ret_lines_1, ret_scores_1 = process_one_file(all_lines_1, cnt_1, score_11, score_12, alpha, gamma)
    ret_lines_2, ret_scores_2 = process_one_file(all_lines_2, cnt_2, score_22, score_21, alpha, gamma)

    winner_lines = find_winner(ret_lines_1, ret_lines_2, ret_scores_1, ret_scores_2)
    newf = tmpF.format(alpha, gamma)
    with open(newf, "w", encoding="utf8") as fw:
        for x in winner_lines:
            print(x, file=fw)
    tgtlng = lng[-2:]
    newcmd = detokenize.format(tgtlng, newf, newf + 'detok')
    os.system(newcmd)
    newcmd = sacrebleu.format(newf + 'detok', year, lng)
    os.system(newcmd)

