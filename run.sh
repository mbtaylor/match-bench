#!/bin/sh

usage="
   Usage: $0 -n <nrow>
"

stilts="stilts"

nrow=1000000
maxarcsec=10

while [ $# -gt 0 ]
do
   key="$1"
   case $key in
      -n)
          nrow="$2"
          shift
          shift
          ;;
      -h|-help|--help)
          echo "$usage"
          exit 0
          ;;
      *)
          echo "$usage"
          exit 1
          ;;
   esac
done

make build

t1=t1-$nrow.fits
t2=t2-$nrow.fits

if [ ! -f $t1 ]
then
   $stilts tpipe in=:skysim:$nrow cmd=progress out=$t1
   echo $t1
fi

if [ ! -f $t2 ]
then
   $stilts -Djel.classes=SkyLib -classpath . \
           tpipe in=$t1 \
           cmd=progress \
           cmd='addcol -units deg ra0 ra' \
           cmd='addcol -units deg dec0 dec' \
           cmd="addcol pos1 randomShiftFlat(ra0,dec0,$maxarcsec/3600.)" \
           cmd='addcol -units deg -ucd "pos.eq.ra;meta.main" ra1 pos1[0]' \
           cmd='addcol -units deg -ucd "pos.eq.dec;meta.main" dec1 pos1[1]' \
           cmd='keepcols "ra1 dec1 ra0 dec0"' \
           cmd='select $0/10>=2' \
           out=$t2
   echo $t2
fi

$stilts -bench \
        tmatch2 progress=log \
                matcher=sky \
                in1=$t1 values1='ra dec' \
                in2=$t2 values2='ra1 dec1' \
                params="$maxarcsec" \
                omode=count 

