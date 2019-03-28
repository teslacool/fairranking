#!/usr/bin/env bash
export CUDA_VISIBLE_DEVICES=0
ckt=$1
datapath=$2
bpetc=$3
year=$4
srclng=$5
lenpen=$6
beamsize=$7
scripts=$SCRIPTS


bpetcdir=/blob/v-jinhzh/data/bpetc/$bpetc
if [ ! -d ${bpetcdir}/model ]
then
    needdetc=false
else
    needdetc=true
    tcdir=$bpetcdir/model
    echo ">>> tcdir $tcdir"
fi
bpedir=$bpetcdir/bpe
echo ">>> bpedir $bpedir"

outputfile=${ckt}.output
srcfile=/blob/v-jinhzh/data/wmttest/testdata/test.${year}.${srclng}.tok
export PYTHONIOENCODING="UTF-8"

APPLY=$scripts/recaser/truecase.perl
if [ "$needdetc" == true ]
then
    echo ">>> $APPLY -model ${tcdir}/tc.${srclng} < $srcfile > input.tok"
    $APPLY -model ${tcdir}/tc.${srclng} < $srcfile > input.tok
else
    echo ">>> cp $srcfile input.tok"
#    cp $srcfile input.tok
fi
BPEROOT=/blob/v-jinhzh/code/subword-nmt/subword_nmt
echo ">>> python $BPEROOT/apply_bpe.py -c $bpedir/$srclng.codes < input.tok > input.tok.bpe"
python $BPEROOT/apply_bpe.py -c $bpedir/$srclng.codes < input.tok > input.tok.bpe

echo ">>> cat input.tok.bpe | python interactive.py $datapath \
--path $ckt --buffer-size 1024 \
--batch-size 128 --beam $beamsize --nbest  $beamsize  --remove-bpe  --lenpen $lenpen > $outputfile"
cat input.tok.bpe | python interactive.py $datapath \
--path $ckt --buffer-size 1024 \
--batch-size 128 --beam $beamsize --nbest  $beamsize  --remove-bpe  --lenpen $lenpen > $outputfile


echo ">>> grep ^H $outputfile | cut -f3- > $outputfile.sys"
grep ^H $outputfile | cut -f3- > $outputfile.sys
echo ">>> rm $outputfile"
rm $outputfile

if [ "$needdetc" = "true" ]
then
    echo ">>> need detruecase.."
    if [ ! -d $scripts ]
    then
        echo "set your mose dir"
        exit
    fi
    echo ">>> perl ${scripts}/recaser/detruecase.perl < $outputfile.sys > $outputfile.sys.tmp"
    perl ${scripts}/recaser/detruecase.perl < "$outputfile".sys > "$outputfile".sys.tmp
    echo ">>> mv $outputfile.sys.tmp $outputfile.sys"
    mv $outputfile.sys.tmp $outputfile.sys
fi

