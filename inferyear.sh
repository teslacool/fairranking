#!/usr/bin/env bash
export PYTHONIOENCODING="UTF-8"
if [ "$1" == "-h" ]
then
    echo "bash *.sh en2ru 2018 lm  cktpath "
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

bpetc=$1
if [ "$bpetc" == 'r2l' ]
then
    r2l=true
else
    r2l=false
fi
echo ">>> bpetc $bpetc"
shift
oldbpetc=$bpetc
bpetc=/blob/v-jinhzh/data/bpetc/$bpetc
if [ ! -d ${bpetc}/model ]
then
    tc=false
else
    tc=true
    tcdir=$bpetc/model
    echo ">>> tcdir $tcdir"
fi
bpedir=$bpetc/bpe
echo ">>> bpedir $bpedir"


#dictdir=$1
#echo ">>> dictdir $dictdir"
#shift

if [ $pair == "ru2en" ]
then
    case $oldbpetc in
        "cold")
        dictdir=/blob/v-jinhzh/data/bt02/warmnmtdata02/ru2en
        ;;
        "lm")
        dictdir=/blob/v-jinhzh/data/bt02/coldnmtdata01/ru2en
        ;;
        "r2l")
        dictdir=/blob/v-jinhzh/data/bt02/coldnmtdata02/ru2en
        ;;
        *)
        echo "unknown bpetc"
        exit
        ;;
    esac
else
    case $oldbpetc in
        "cold")
        dictdir=/blob/v-jinhzh/data/bt02/warmnmtdata04/en2ru
        ;;
        "lm")
        dictdir=/blob/v-jinhzh/data/bt02/coldnmtdata01/en2ru
        ;;
        "r2l")
        dictdir=/blob/v-jinhzh/data/bt02/coldnmtdata09/en2ru
        ;;
        *)
        echo "unknown bpetc"
        exit
        ;;
    esac
fi
echo ">>> dictdir $dictdir"
cktpath=$1
echo ">>> cktpath $cktpath"
shift

srcfile=/blob/v-jinhzh/data/wmttest/testdata/test.${year}.${src}.tok
SCRIPTS=/blob/v-jinhzh/code/mosesdecoder/scripts
APPLY=$SCRIPTS/recaser/truecase.perl
echo ">>> srcfile ${srcfile}"
if [ "$tc" == true ]
then
    echo ">>> $APPLY -model ${tcdir}/tc.${src} < $srcfile > input.tok"
    $APPLY -model ${tcdir}/tc.${src} < $srcfile > input.tok
else
    echo ">>> cp $srcfile input.tok"
    cp $srcfile input.tok
fi
BPEROOT=/blob/v-jinhzh/code/subword-nmt/subword_nmt
echo ">>> python $BPEROOT/apply_bpe.py -c $bpedir/$src.codes < input.tok > input.tok.bpe"
python $BPEROOT/apply_bpe.py -c $bpedir/$src.codes < input.tok > input.tok.bpe

beamsize=5
lenpen=1
if [ $pair == "en2ru" ]
then
    beamsize=10
    lenpen=0.4
else
    beamsize=5
    lenpen=1.5
fi
#r2l=false
bsz=128
while [[ $# > 0 ]]
do
key="$1"
case $key in
    -b|--beamsize)
    beamsize=$2
    shift
    ;;
    -l|--lenpen)
    lenpen=$2
    shift
    ;;
    --r2l)
    r2l=true
    ;;
    --bsz)
    bsz=$2
    shift
    ;;
    *)
    echo "unknown args $1"
    exit
    ;;
esac
shift
done
echo ">>> beamsize $beamsize"
echo ">>> lenpen $lenpen"
echo ">>> r2l $r2l"
echo ">> bsz $bsz"

echo ">>> cat input.tok.bpe | python interactive.py $dictdir \
--path $cktpath --buffer-size 1024 \
--batch-size $bsz --beam $beamsize  --remove-bpe  --lenpen $lenpen > output.log"
cat input.tok.bpe | python interactive.py $dictdir \
--path $cktpath --buffer-size 1024 \
--batch-size $bsz --beam $beamsize  --remove-bpe  --lenpen $lenpen > output.log

echo ">>> grep ^H output.log | cut -f3- > output.tok"
grep ^H output.log | cut -f3- > output.tok
if [ $r2l == true ]
then
    echo "python reversesentence.py output.tok"
    python reversesentence.py output.tok
    echo "mv output.tok.reversed output.tok"
    mv output.tok.reversed output.tok
fi

if [ "$tc" == true ]
then
    echo ">>> perl ../mosesdecoder/scripts/recaser/detruecase.perl < output.tok > output.tok.detc"
    perl ../mosesdecoder/scripts/recaser/detruecase.perl < output.tok > output.tok.detc
    echo ">>> mv output.tok.detc output.tok"
    mv output.tok.detc output.tok
fi

echo ">>> perl ../mosesdecoder/scripts/tokenizer/detokenizer.perl -l $tgt < output.tok > output.tok.detok"
perl ../mosesdecoder/scripts/tokenizer/detokenizer.perl -l $tgt < output.tok > output.tok.detok
echo ">>> cat output.tok.detok | ../sockeye/sockeye_contrib/sacrebleu/sacrebleu.py -t wmt${year:2:2} -l ${src}-${tgt}"
cat output.tok.detok | ../sockeye/sockeye_contrib/sacrebleu/sacrebleu.py -t wmt${year:2:2} -l ${src}-${tgt}

