#!/usr/bin/env bash
HOME=/blob/v-jinhzh/code/fairranking
cd $HOME

bperoot=/blob/v-jinhzh/code/subword-nmt/subword_nmt
export BPEROOT=$bperoot
scripts=/blob/v-jinhzh/code/mosesdecoder/scripts
export SCRIPTS=$scripts

if [ $1 == '-h' ]
then
echo "bash  rankmulti.sh ru2en 2018 1. 5 ckt1 datapath1 bpetc1 bsz1 -  ckt2 datapath2 bpetc2 ... "
exit
fi
pair=$1
src=${pair:0:2}
tgt=${pair:3:2}
echo ">>> srclng $src"
echo ">>> tgtlng $tgt"
shift
year=$1
echo ">>> year $year"
shift

lenpen=$1
echo ">>> lenpen $lenpen"
shift
beamsize=$1
echo ">>> beamsize $beamsize"
shift




ensembleid=0
while [ ! "$1" == '-' ]
do
enckts[$ensembleid]=$1
shift
endatapaths[$ensembleid]=$1
shift
enbpetcs[$ensembleid]=$1
shift
enbszs[$ensembleid]=$1
shift
echo ">>> enckt ${enckts[$ensembleid]} endatapath ${endatapaths[$ensembleid]} enbpetc ${enbpetcs[$ensembleid]} enbsz  ${enbszs[$ensembleid]}"
ensembleid=$[ensembleid+1]
done
shift
tmp=$#
tmp=$[tmp%3]
if [ $tmp != 0 ]
then
echo "args number must be divisible by 3"
exit
fi
id=0
while [[ $# > 0 ]]
do
ckts[$id]=$1
shift
datapaths[$id]=$1
shift
bpetcs[$id]=$1
shift
echo ">>> ckt ${ckts[$id]} datapath ${datapaths[$id]} bpetc ${bpetcs[$id]} "
id=$[id+1]
done

totalcktnum=$id
stopcnt=$[totalcktnum-1]
enstopcnt=$[ensembleid-1]
for id in `seq 0 $enstopcnt`
do
    echo ">>> bash enmultiinfer.sh ${enckts[$id]} ${endatapaths[$id]} ${enbpetcs[$id]} $year $src  $lenpen $beamsize ${enbszs[$id]} "
    bash enmultiinfer.sh ${enckts[$id]} ${endatapaths[$id]} ${enbpetcs[$id]} $year $src  $lenpen $beamsize ${enbszs[$id]}
    echo ">>> ensembleoutput.sys ensembleoutput.sys.$id"
    mv ensembleoutput.sys ensembleoutput.sys.$id
done
if [ -f input.tok ]
then
    echo ">>> rm input.tok"
    rm input.tok
fi
if [ -f output.sys ]
then
    echo ">>> rm output.sys"
    rm output.sys

fi
srcfile=/blob/v-jinhzh/data/wmttest/testdata/test.${year}.${src}.tok
for id in `seq 0 $enstopcnt`
do
    echo ">>> cat $srcfile >> input.tok "
    cat $srcfile >> input.tok
    echo ">>> wc -l  ensembleoutput.sys.$id"
    wc -l  ensembleoutput.sys.$id
    echo ">>> cat ensembleoutput.sys.$id >> output.sys"
    cat ensembleoutput.sys.$id >> output.sys
    echo ">>> rm ensembleoutput.sys.$id"
    rm ensembleoutput.sys.$id
done

echo "echo wc -l output.sys"
wc -l output.sys

for id in `seq 0 $stopcnt`
do
    echo ">>> bash multieval.sh ${ckts[$id]} ${datapaths[$id]} ${bpetcs[$id]} $year $src  $lenpen $beamsize $tgt"
    bash multieval.sh ${ckts[$id]} ${datapaths[$id]} ${bpetcs[$id]} $year $src  $lenpen $beamsize $tgt
    echo ">>> mv output.score output.score.${id}"
    mv output.score output.score.${id}
    echo ">>> wc -l output.score.${id}"
    wc -l output.score.${id}
    echo ">>> rm input.tok.bpe"
    rm input.tok.bpe
    echo ">>> rm output.sys.bpe"
    rm output.sys.bpe
done
if [ -f output.score ]
then
    echo ">>> rm output.score"
    rm output.score
fi
for id in `seq 0 $stopcnt`
do
    echo ">>> cat output.score.${id} >> output.score"
    cat output.score.${id} >> output.score
    echo ">>> rm output.score.${id}"
    rm output.score.${id}
done
echo "wc -l output.score"
wc -l output.score
python encal.py $beamsize $ensembleid
echo ">>> python threecal.py $beamsize $ensembleid $tgt"
echo ">>> perl ../mosesdecoder/scripts/tokenizer/detokenizer.perl -l $tgt < output.tok > output.tok.detok"
perl ../mosesdecoder/scripts/tokenizer/detokenizer.perl -l $tgt < output.tok > output.tok.detok
echo ">>> cat output.tok.detok | ../sockeye/sockeye_contrib/sacrebleu/sacrebleu.py /blob/v-jinhzh/data/wmttest/testdata/${src}${tgt}.${tgt}"
cat output.tok.detok | ../sockeye/sockeye_contrib/sacrebleu/sacrebleu.py /blob/v-jinhzh/data/wmttest/testdata/${src}${tgt}.${tgt}