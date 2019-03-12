#!/usr/bin/env bash
# bash reranking.sh 0 checkpoints/transformer/checkpoint1.pt data-bin/iwslt14.tokenized.de-en/ checkpoints/transformer/checkpoint2.pt data-bin/iwslt14.tokenized.de-en/
gpuid=0
HOME=/home/v-jinhzh/code/fairranking
cd $HOME

src=en
tgt=ru
bperoot=/home/v-jinhzh/code/subword-nmt/subword_nmt
export BPEROOT=$bperoot
scripts=/home/v-jinhzh/code/mosesdecoder/scripts
export SCRIPTS=$scripts

ckt1=checkpoints/transformer/checkpoint1.pt
datapath1=data-bin/iwslt14.tokenized.de-en/
bpetc1=/blob/v-jinhzh/data/bpetc/share
needtc1=false

ckt2=checkpoints/transformer/checkpoint2.pt
datapath2=data-bin/iwslt14.tokenized.de-en/
bpetc2=/blob/v-jinhzh/data/bpetc/cold
needtc2=true


echo ""
bash infer.sh $gpuid $ckt1 $datapath1
bash infer.sh $gpuid $ckt2 $datapath2
if [ $needtc1 == true ]
then
    perl ${scripts}/recaser/detruecase.perl < ${ckt1}.sys > ${ckt1}.sys.detc
    ckt1ouput=${ckt1}.sys.detc
    perl ${scripts}/recaser/detruecase.perl < ${ckt1}.src > ${ckt1}.src.detc
    srcinput=${ckt1}.src.detc
else
    ckt1ouput=${ckt1}.sys
    srcinput=${ckt1}.src
fi
if [ $needtc2 == true ]
then
    perl ${scripts}/recaser/detruecase.perl < ${ckt2}.sys > ${ckt2}.sys.detc
    ckt2ouput=${ckt2}.sys.detc
else
    ckt2ouput=${ckt2}.sys.detc
fi
echo "ckt1ouput $ckt1ouput"
echo "ckt2ouput $ckt2ouput"
echo "srcinput $srcinput"

if [ $needtc1 == true ]
then
    perl ${scripts}/recaser/truecase.perl < ${ckt1}.sys > ${ckt1}.sys.detc
    ckt1ouput=${ckt1}.sys.detc
else
    ckt1ouput=${ckt1}.sys.detc
fi
if [ $needtc2 == true ]
then
    perl ${scripts}/recaser/detruecase.perl < ${ckt2}.sys > ${ckt2}.sys.detc
    ckt2ouput=${ckt2}.sys.detc
else
    ckt2ouput=${ckt2}.sys.detc
fi






bash eval.sh $gpuid $datapath1 $ckt1 $ckt1 0
bash eval.sh $gpuid $datapath2 $ckt2 $ckt1 1

bash eval.sh $gpuid $datapath2 $ckt2 $ckt2 0
bash eval.sh $gpuid $datapath1 $ckt1 $ckt2 1

