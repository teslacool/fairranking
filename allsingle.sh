#!/usr/bin/env bash
src=ru
tgt=en
cktdir=checkpoints/ru2enfinalmodel
echo "src $src tgt $tgt"
if [ -f kd.${src}${tgt}.${tgt} ]
then
    echo "kd.${src}${tgt}.${tgt} exist!"
    exit
fi
for year in 2016 2017 2018; do
    bash inferyear.sh ${src}2${tgt} $year cold $cktdir/model1.pt
    cat /blob/v-jinhzh/data/wmttest/testdata/test.${year}.${src}.tok >> kd.${src}${tgt}.${src}
    cat output.tok >> kd.${src}${tgt}.${tgt}
    bash inferyear.sh ${src}2${tgt} $year cold $cktdir/model2.pt
    cat /blob/v-jinhzh/data/wmttest/testdata/test.${year}.${src}.tok >> kd.${src}${tgt}.${src}
    cat output.tok >> kd.${src}${tgt}.${tgt}
    bash inferyear.sh ${src}2${tgt} $year lm $cktdir/model3.pt
    cat /blob/v-jinhzh/data/wmttest/testdata/test.${year}.${src}.tok >> kd.${src}${tgt}.${src}
    cat output.tok >> kd.${src}${tgt}.${tgt}
    bash inferyear.sh ${src}2${tgt} $year lm $cktdir/model4.pt
    cat /blob/v-jinhzh/data/wmttest/testdata/test.${year}.${src}.tok >> kd.${src}${tgt}.${src}
    cat output.tok >> kd.${src}${tgt}.${tgt}
    bash inferyear.sh ${src}2${tgt} $year lm $cktdir/model5.pt
    cat /blob/v-jinhzh/data/wmttest/testdata/test.${year}.${src}.tok >> kd.${src}${tgt}.${src}
    cat output.tok >> kd.${src}${tgt}.${tgt}
    bash inferyear.sh ${src}2${tgt} $year lm $cktdir/model6.pt
    cat /blob/v-jinhzh/data/wmttest/testdata/test.${year}.${src}.tok >> kd.${src}${tgt}.${src}
    cat output.tok >> kd.${src}${tgt}.${tgt}
    bash inferyear.sh ${src}2${tgt} $year r2l $cktdir/model7.pt
    cat /blob/v-jinhzh/data/wmttest/testdata/test.${year}.${src}.tok >> kd.${src}${tgt}.${src}
    cat output.tok >> kd.${src}${tgt}.${tgt}
done


src=en
tgt=ru
cktdir=checkpoints/en2rufinalmodel
echo "src $src tgt $tgt"
if [ -f kd.${src}${tgt}.${tgt} ]
then
    echo "kd.${src}${tgt}.${tgt} exist!"
    exit
fi
for year in 2016 2017 2018; do
    bash inferyear.sh ${src}2${tgt} $year cold $cktdir/model1.pt
    cat /blob/v-jinhzh/data/wmttest/testdata/test.${year}.${src}.tok >> kd.${src}${tgt}.${src}
    cat output.tok >> kd.${src}${tgt}.${tgt}
    bash inferyear.sh ${src}2${tgt} $year cold $cktdir/model2.pt
    cat /blob/v-jinhzh/data/wmttest/testdata/test.${year}.${src}.tok >> kd.${src}${tgt}.${src}
    cat output.tok >> kd.${src}${tgt}.${tgt}
    bash inferyear.sh ${src}2${tgt} $year lm $cktdir/model3.pt
    cat /blob/v-jinhzh/data/wmttest/testdata/test.${year}.${src}.tok >> kd.${src}${tgt}.${src}
    cat output.tok >> kd.${src}${tgt}.${tgt}
    bash inferyear.sh ${src}2${tgt} $year lm $cktdir/model4.pt
    cat /blob/v-jinhzh/data/wmttest/testdata/test.${year}.${src}.tok >> kd.${src}${tgt}.${src}
    cat output.tok >> kd.${src}${tgt}.${tgt}
    bash inferyear.sh ${src}2${tgt} $year r2l $cktdir/model5.pt
    cat /blob/v-jinhzh/data/wmttest/testdata/test.${year}.${src}.tok >> kd.${src}${tgt}.${src}
    cat output.tok >> kd.${src}${tgt}.${tgt}
    bash inferyear.sh ${src}2${tgt} $year r2l $cktdir/model6.pt
    cat /blob/v-jinhzh/data/wmttest/testdata/test.${year}.${src}.tok >> kd.${src}${tgt}.${src}
    cat output.tok >> kd.${src}${tgt}.${tgt}
done