import io
import os
import sys
srcfn = sys.argv[1]
tgtfn = srcfn + '.reversed'
assert os.path.exists(srcfn)
with io.open(srcfn, 'r', encoding='utf8', newline='\n') as src:
    with io.open(tgtfn, 'w', encoding='utf8', newline='\n') as tgt:
        for line in src:
            words = line.strip().split()
            words.reverse()
            newline = ' '.join(words)
            tgt.write(newline + '\n')