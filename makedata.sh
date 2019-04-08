#!/usr/bin/env bash
export PYTHONIOENCODING="UTF-8"
if [ "$1" == "-h" ]
then
    echo "bash makedata.sh textdir en2ru lm "
    exit
fi
textdir=$1
echo ">>> textdir $textdir"

shift
pair=$1
src=${pair:0:2}
tgt=${pair:3:2}
echo ">>> srclng $src"
echo ">>> tgtlng $tgt"
shift
tgtdir=$textdir/$pair
mkdir -p $tgtdir

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


srcfile=${textdir}/kd.${src}${tgt}.${src}
tgtfile=${textdir}/kd.${src}${tgt}.${tgt}
echo ">>> srcfile $srcfile tgtfile $tgtfile"

SCRIPTS=/blob/v-jinhzh/code/mosesdecoder/scripts
APPLY=$SCRIPTS/recaser/truecase.perl
if [ "$tc" == true ]
then
    echo ">>> $APPLY -model ${tcdir}/tc.${src} < $srcfile > ${srcfile}.tc"
    $APPLY -model ${tcdir}/tc.${src} < $srcfile > ${srcfile}.tc
    echo ">>> $APPLY -model ${tcdir}/tc.${tgt} < $tgtfile > ${tgtfile}.tc"
    $APPLY -model ${tcdir}/tc.${tgt} < $tgtfile > ${tgtfile}.tc
else
    echo ">>> cp $srcfile ${srcfile}.tc"
    cp $srcfile ${srcfile}.tc
    echo ">>> cp $tgtfile ${tgtfile}.tc"
    cp $tgtfile ${tgtfile}.tc
fi
echo ">>> r2l $r2l"
if [ $r2l == true ]
then
    echo "python reversesentence.py ${srcfile}.tc"
    python reversesentence.py ${srcfile}.tc
    echo "mv ${srcfile}.tc.reversed ${srcfile}.tc"
    mv ${srcfile}.tc.reversed ${srcfile}.tc
    echo "python reversesentence.py ${tgtfile}.tc"
    python reversesentence.py ${tgtfile}.tc
    echo "mv ${tgtfile}.tc.reversed ${tgtfile}.tc"
    mv ${tgtfile}.tc.reversed ${tgtfile}.tc
fi
BPEROOT=/blob/v-jinhzh/code/subword-nmt/subword_nmt
echo ">>> python $BPEROOT/apply_bpe.py -c $bpedir/$src.codes < ${srcfile}.tc > $tgtdir/train.$src"
python $BPEROOT/apply_bpe.py -c $bpedir/$src.codes < ${srcfile}.tc > $tgtdir/train.$src
echo ">>> python $BPEROOT/apply_bpe.py -c $bpedir/$tgt.codes < ${tgtfile}.tc > $tgtdir/train.$tgt"
python $BPEROOT/apply_bpe.py -c $bpedir/$tgt.codes < ${tgtfile}.tc > $tgtdir/train.$tgt

echo "head -n 100 $tgtdir/train.$src > $tgtdir/valid.$src"
head -n 100 $tgtdir/train.$src > $tgtdir/valid.$src
echo "head -n 100 $tgtdir/train.$tgt > $tgtdir/valid.$tgt"
head -n 100 $tgtdir/train.$tgt > $tgtdir/valid.$tgt

echo "python preprocess.py --source-lang $src --target-lang $tgt \
--trainpref $tgtdir/train --validpref $tgtdir/valid \
--destdir $tgtdir --workers 32 \
--srcdict $dictdir/dict.${src}.txt --tgtdict $dictdir/dict.${tgt}.txt"
python preprocess.py --source-lang $src --target-lang $tgt \
--trainpref $tgtdir/train --validpref $tgtdir/valid \
--destdir $tgtdir --workers 32 \
--srcdict $dictdir/dict.${src}.txt --tgtdict $dictdir/dict.${tgt}.txt

rm ${srcfile}.tc
rm ${tgtfile}.tc


