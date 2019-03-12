#!/usr/bin/env bash
# bash reranking.sh 0 checkpoints/transformer/checkpoint1.pt data-bin/iwslt14.tokenized.de-en/ checkpoints/transformer/checkpoint2.pt data-bin/iwslt14.tokenized.de-en/
gpuid=0
HOME=/blob/v-jinhzh/code/fairranking
cd $HOME

src=en
tgt=ru
bperoot=/blob/v-jinhzh/code/subword-nmt/subword_nmt
export BPEROOT=$bperoot
scripts=/blob/v-jinhzh/code/mosesdecoder/scripts
export SCRIPTS=$scripts

ckt1=/blob/v-jinhzh/code/fairseq_baseline/checkpoints/bt02_warm_share_en2ru/checkpoint30.pt
datapath1=/blob/v-jinhzh/data/bt02/warmnmtdata01/en2ru
bpetc1=/blob/v-jinhzh/data/bpetc/share
needtc1=false

ckt2=/blob/v-jinhzh/code/fairseq_baseline/checkpoints/bt02_warm_cold_en2ru/checkpoint11.pt
datapath2=/blob/v-jinhzh/data/bt02/warmnmtdata02/en2ru
bpetc2=/blob/v-jinhzh/data/bpetc/cold
needtc2=true

year=wmt18

echo "bash infer.sh $gpuid $ckt1 $datapath1 $needtc1
bash infer.sh $gpuid $ckt2 $datapath2 $needtc2"

bash infer.sh $gpuid $ckt1 $datapath1 $needtc1
bash infer.sh $gpuid $ckt2 $datapath2 $needtc2

echo "bash eval.sh $gpuid $datapath1 $ckt1 $ckt1 0 $bpetc1 $needtc1 $src $tgt
bash eval.sh $gpuid $datapath2 $ckt2 $ckt1 1 $bpetc2 $needtc2 $src $tgt
bash eval.sh $gpuid $datapath2 $ckt2 $ckt2 0 $bpetc2 $needtc2 $src $tgt
bash eval.sh $gpuid $datapath1 $ckt1 $ckt2 1 $bpetc1 $needtc1 $src $tgt"

bash eval.sh $gpuid $datapath1 $ckt1 $ckt1 0 $bpetc1 $needtc1 $src $tgt
bash eval.sh $gpuid $datapath2 $ckt2 $ckt1 1 $bpetc2 $needtc2 $src $tgt

bash eval.sh $gpuid $datapath2 $ckt2 $ckt2 0 $bpetc2 $needtc2 $src $tgt
bash eval.sh $gpuid $datapath1 $ckt1 $ckt2 1 $bpetc1 $needtc1 $src $tgt

python cal.py $ckt1 $ckt2 ${src}-${tgt} $year
