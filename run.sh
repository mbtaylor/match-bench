#!/bin/sh

usage="
   Usage: $0 -n <nrow> -stilts <stilts-cmd>
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
      -stilts)
          stilts="$2"
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

t0=t0-$nrow.fits
t1=t1-$nrow.fits
t2=t2-$nrow.fits

if [ ! -f $t0 -o ! -f $t1 -o ! -f $t2 ]
then
   rm -f $t0 $t1 $t2

   $stilts tpipe in=:skysim:$nrow cmd=progress out=$t0
   echo $t0

   $stilts tpipe in=$t0 \
           cmd=progress \
           cmd='select $0%11>=2' \
           out=$t1
   echo $t1
   $stilts tpipe in=$t1 omode=count

   $stilts -Djel.classes=SkyLib -classpath . \
           tpipe in=$t0 \
           cmd=progress \
           cmd='addcol -units deg ra0 ra' \
           cmd='addcol -units deg dec0 dec' \
           cmd="addcol pos1 randomShiftFlat(ra0,dec0,$maxarcsec/3600.)" \
           cmd='addcol -units deg -ucd "pos.eq.ra;meta.main" ra1 pos1[0]' \
           cmd='addcol -units deg -ucd "pos.eq.dec;meta.main" dec1 pos1[1]' \
           cmd='keepcols "ra1 dec1 ra0 dec0"' \
           cmd='select $0%10>=2' \
           out=$t2
   echo $t2
   $stilts tpipe in=$t2 omode=count
fi

cmd="$stilts -J-ea -bench \
        tmatch2 progress=log \
                matcher=sky \
                in1=$t1 values1='ra dec' \
                in2=$t2 values2='ra1 dec1' \
                params="$maxarcsec" \
                find=best \
                omode=checksum"
echo $cmd
eval $cmd

