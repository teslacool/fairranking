#!/usr/bin/env bash
tgt=$1
if [ $tgt == en ]
then
    src=ru
    srcsgmlfile=/blob/v-jinhzh/data/wmttest/test/newstest2019-ruen-src-ts.ru.sgm
else
    src=en
    srcsgmlfile=/blob/v-jinhzh/data/wmttest/test/newstest2019-enru-src-ts.en.sgm
fi
echo "wrap-xml.perl $tgt $srcsgmlfile dadi < output.tok.detok > output.tok.detok.sgm"
perl wrap-xml.perl $tgt $srcsgmlfile dadi < output.tok.detok > output.tok.detok.sgm
echo "wrap-xml.perl $tgt $srcsgmlfile dadi < output.tok.detok > output.tok.detok.sgm"