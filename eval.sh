#!/usr/bin/env bash
export CUDA_VISIBLE_DEVICES=$1
DATA_PATH=$2
ckt=$3
srcckt=$4
id=$5
bpetc=$6
needtc=$7
scripts=$SCRIPTS
srclng=$8
tgtlng=$9

beamsize=5

if [ "$needtc" = "true" ]
then
    echo "apply truecase"
    ${scripts}/recaser/truecase.perl -model  ${bpetc}/model/model.tc.${srclng} < ${srcckt}.output.src > ${srcckt}.output.src.tmp
    srcsrc=${srcckt}.output.src.tmp
    ${scripts}/recaser/truecase.perl -model  ${bpetc}/model/model.tc.${tgtlng} < ${srcckt}.output.sys > ${srcckt}.output.sys.tmp
    srcsys=${srcckt}.output.sys.tmp
else
    srcsrc=${srcckt}.output.src
    srcsys=${srcckt}.output.sys
fi

python ${BPEROOT}/apply_bpe.py -c ${bpetc}/bpe/${srclng}.codes < ${srcsrc} >  ${srcckt}.output.src.$id
python ${BPEROOT}/apply_bpe.py -c ${bpetc}/bpe/${tgtlng}.codes < ${srcsys} >  ${srcckt}.output.sys.$id

python eval.py $DATA_PATH \
--path $ckt \
--source-file ${srcckt}.output.src.$id \
--target-file ${srcckt}.output.sys.$id \
--score-file  ${srcckt}.output.${id} \
--dup-src $beamsize \
--dup-tgt 1 \
--max-tokens 4096