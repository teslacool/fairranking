import numpy as np
import sys
import os
import re

prefix_1 = "/hdfs/sdrgvc/yinxia/pytorch/models/{}_trans".format(sys.argv[1])
prefix_2 = "/hdfs/sdrgvc/yinxia/pytorch/models/wmt14_en_fr_FB_trans"

input_1 = prefix_1 + "/trans_allbeams5_{}.sys".format(sys.argv[2])
input_2 = prefix_2 + "/trans_allbeams5_best.sys"
score_11 = prefix_1 + "/trans_allbeams5_{}.score".format(sys.argv[2])
score_12 = prefix_1 + "/trans_allbeams5_{}_tgtbest.score".format(sys.argv[2])
score_21 = prefix_2 + "/trans_allbeams5_best.score"
score_22 = prefix_2 + "/trans_allbeams5_best_tgt{}.score".format(sys.argv[2])

tmpF = score_22.split("/")[-1] + "__tmp"

bleulog = "./bleulog/bleu-" + sys.argv[1] + "-" + sys.argv[2]

ref = ""

beamsize = 5

perl_script = "perl /var/storage/shared/sdrgvc/v-yixia/transformer-coder/tiny-moses/multi-bleu.pl /hdfs/sdrgvc/yinxia/pytorch/models/wmt14_en_fr_FB_trans/trans_allbeams5_best.ref.debpe < " + tmpF + " >> " + bleulog


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

gamma = -0.4

max_bin = 20

for aa in range(max_bin + 1):
    alpha = aa / max_bin
    alpha = 1. - alpha
    ret_lines_1, ret_scores_1 = process_one_file(all_lines_1, cnt_1, score_11, score_12, alpha, gamma)
    ret_lines_2, ret_scores_2 = process_one_file(all_lines_2, cnt_2, score_22, score_21, alpha, gamma)

    winner_lines = find_winner(ret_lines_1, ret_lines_2, ret_scores_1, ret_scores_2)
    with open(tmpF, "w", encoding="utf8") as fw:
        for x in winner_lines:
            print(re.sub("(@@ )|(@@?$)", "", x), file=fw)
    # os.system("cat __tmp")
    os.system(perl_script)
    os.system("rm " + tmpF)

