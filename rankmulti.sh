#!/usr/bin/env bash
HOME=/blob/v-jinhzh/code/fairranking
cd $HOME

bperoot=/blob/v-jinhzh/code/subword-nmt/subword_nmt
export BPEROOT=$bperoot
scripts=/blob/v-jinhzh/code/mosesdecoder/scripts
export SCRIPTS=$scripts

if [ $1 == '-h' ]
then
echo "bash  rankmulti.sh ru2en 2018 1. 5 ckt1 datapath1 bpetc1 ckt2 datapath2 bpetc2 ... "
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
for id in `seq 0 $stopcnt`
do
    echo ">>> bash multiinfer.sh ${ckts[$id]} ${datapaths[$id]} ${bpetcs[$id]} $year $src  $lenpen $beamsize"
    bash multiinfer.sh ${ckts[$id]} ${datapaths[$id]} ${bpetcs[$id]} $year $src  $lenpen $beamsize
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
for id in `seq 0 $stopcnt`
do
    echo ">>> cat $srcfile >> input.tok "
    cat $srcfile >> input.tok
    echo ">>> cat ${ckts[$id]}.output.sys >> output.sys"
    cat ${ckts[$id]}.output.sys >> output.sys
    echo ">>> rm ${ckts[$id]}.output.sys"
    rm ${ckts[$id]}.output.sys
done

for id in `seq 0 $stopcnt`
do
    echo ">>> bash multieval.sh ${ckts[$id]} ${datapaths[$id]} ${bpetcs[$id]} $year $src  $lenpen $beamsize $tgt"
    bash multieval.sh ${ckts[$id]} ${datapaths[$id]} ${bpetcs[$id]} $year $src  $lenpen $beamsize $tgt
    echo ">>> mv output.score output.score.${id}"
    mv output.score output.score.${id}
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