#!/usr/bin/env bash
export CUDA_VISIBLE_DEVICES=$1
ckt=$2
datapath=$3
needdetc=$4
bpetc=$5
testdata=$6
srclng=$7

scripts=$SCRIPTS
beamsize=5


outputfile=${ckt}.output

export PYTHONIOENCODING="UTF-8"
if [ "$needdetc" = "true"  ]
then
    cat $testdata | \
    perl ${scripts}/recaser/truecase.perl -model  ${bpetc}/model/tc.${srclng} | \
    python ${BPEROOT}/apply_bpe.py -c ${bpetc}/bpe/${srclng}.codes > ${ckt}.testinput
else
    cat $testdata | \
    python ${BPEROOT}/apply_bpe.py -c ${bpetc}/bpe/${srclng}.codes > ${ckt}.testinput
fi

echo "
cat ${ckt}.testinput | python interactive.py  $datapath \
--path $ckt --buffer-size 1024 \
--batch-size 128 --beam $beamsize --nbest  $beamsize --remove-bpe  > $outputfile
"
cat ${ckt}.testinput | python interactive.py  $datapath \
--path $ckt --buffer-size 1024 \
--batch-size 128 --beam $beamsize --nbest  $beamsize --remove-bpe  > $outputfile

#python generate.py $datapath \
#--path $ckt \
#--batch-size 128 --beam $beamsize --nbest  $beamsize --remove-bpe > $outputfile



grep ^H $outputfile | cut -f3- > "$outputfile".sys

#grep ^T $outputfile | cut -f2- > "$outputfile".ref

grep ^S $outputfile | cut -f2- > "$outputfile".src

if [ "$needdetc" = "true" ]
then
    echo "need detruecase.."
    if [ ! -d $scripts ]
    then
        echo "set your mose dir"
        exit
    fi
    ${scripts}/recaser/detruecase.perl < "$outputfile".src > "$outputfile".src.tmp
    mv $outputfile.src.tmp "$outputfile".src
    ${scripts}/recaser/detruecase.perl < "$outputfile".sys > "$outputfile".sys.tmp
    mv $outputfile.sys.tmp "$outputfile".sys
fi
