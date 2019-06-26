import io
import argparse
import os
parser = argparse.ArgumentParser()
parser.add_argument('path', type=str)
args = parser.parse_args()
path = args.path
path = os.path.join(path, 'bleu.logs')
if not os.path.exists(path):
    print('file {} does not exist'.format(path))
    exit()

best_bleu = 0
best_ckt = ''
all_lines = io.open(path, 'r', encoding='utf8', newline='\n').readlines()
for i, line in enumerate(all_lines):
    if line.startswith('|'):
        ws = line.strip().split()[7][:-1]
        ws = float(ws)
        if ws > best_bleu:
            best_bleu = ws
            best_ckt = all_lines[i-1].strip()
print('best bleu {} {}'.format(best_ckt, best_bleu))