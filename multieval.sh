#!/usr/bin/env bash
export CUDA_VISIBLE_DEVICES=0
ckt=$1
datapath=$2
bpetc=$3
year=$4
srclng=$5
lenpen=$6
beamsize=$7
tgtlng=$8
scripts=$SCRIPTS

BPEROOT=/blob/v-jinhzh/code/subword-nmt/subword_nmt
bpetcdir=/blob/v-jinhzh/data/bpetc/$bpetc
if [ ! -d ${bpetcdir}/model ]
then
    needtc=false
else
    needtc=true
    tcdir=$bpetcdir/model
    echo ">>> tcdir $tcdir"
fi
bpedir=$bpetcdir/bpe
echo ">>> bpedir $bpedir"
outputsys="output.sys"
if [ $bpetc == "r2l" ]
then
    echo ">>> python reversesentence.py output.sys"
    python reversesentence.py output.sys
    outputsys=output.sys.reversed
fi
echo ">>> outputsys $outputsys"
if [ "$needtc" = "true" ]
then
    echo ">>> apply truecase"
    echo ">>> cat input.tok | \
    perl ${scripts}/recaser/truecase.perl -model  ${bpetcdir}/model/tc.${srclng} | \
    python ${BPEROOT}/apply_bpe.py -c ${bpetcdir}/bpe/${srclng}.codes >  input.tok.bpe"
    cat input.tok | \
    perl ${scripts}/recaser/truecase.perl -model  ${bpetcdir}/model/tc.${srclng} | \
    python ${BPEROOT}/apply_bpe.py -c ${bpetcdir}/bpe/${srclng}.codes >  input.tok.bpe

    echo ">>> cat output.sys | \
    perl ${scripts}/recaser/truecase.perl -model  ${bpetcdir}/model/tc.${tgtlng} | \
    python ${BPEROOT}/apply_bpe.py -c ${bpetcdir}/bpe/${tgtlng}.codes >  output.sys.bpe"
    cat output.sys | \
    perl ${scripts}/recaser/truecase.perl -model  ${bpetcdir}/model/tc.${tgtlng} | \
    python ${BPEROOT}/apply_bpe.py -c ${bpetcdir}/bpe/${tgtlng}.codes >  output.sys.bpe
else
    echo "cat input.tok | \
    python ${BPEROOT}/apply_bpe.py -c ${bpetcdir}/bpe/${srclng}.codes >  input.tok.bpe"
    cat input.tok | \
    python ${BPEROOT}/apply_bpe.py -c ${bpetcdir}/bpe/${srclng}.codes >  input.tok.bpe

    echo "cat $outputsys | \
    python ${BPEROOT}/apply_bpe.py -c ${bpetcdir}/bpe/${tgtlng}.codes >  output.sys.bpe"
    cat $outputsys | \
    python ${BPEROOT}/apply_bpe.py -c ${bpetcdir}/bpe/${tgtlng}.codes >  output.sys.bpe
    if [ $bpetc == "r2l" ]
    then
        echo ">>> rm $outputsys"
        rm $outputsys
    fi
fi
export PYTHONIOENCODING="UTF-8"
echo ">>> python eval.py $datapath \
--path $ckt \
--source-file input.tok.bpe \
--target-file output.sys.bpe \
--score-file  output.score \
--dup-src $beamsize \
--dup-tgt 1 \
--max-tokens 4096"
python eval.py $datapath \
--path $ckt \
--source-file input.tok.bpe \
--target-file output.sys.bpe \
--score-file  output.score \
--dup-src $beamsize \
--dup-tgt 1 \
--max-tokens 4096

