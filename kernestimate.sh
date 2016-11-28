#!/bin/bash
# iterative script

eval `vshparse if= of= - with $0 $*`
#evaluate a "-" argument
if [ "x"$OPT = "x-" ] ; then 
echo "$pname:         create a displayable image from a complex image" 1>&2
echo "[if=]  a two channel (complex) image input  " 1>&2
echo "[of=]  a scaled byte image output suitable for display " 1>&2
exit
fi

eval $(vps if=$if -sh)
xlog=$(echo "l($psx)/l(2)"|bc -l) #have to round the log down to know padding number
roundxlog=$(echo "$xlog/1+1"|bc)
ylog=$(echo "l($psy)/l(2)"|bc -l)
roundylog=$(echo "$ylog/1+1"|bc)
magx=$(echo "2^($roundxlog)/$psx"|bc -l)
magy=$(echo "2^($roundylog)/$psy"|bc -l)
vmag if=$if of=magged m=$magx,$magy
vfft if=magged of=fft_$if #fft of the padded image
vchan if=fft_$if -mp | vchan c=1 of=magfft
xl=$(echo "(0.4*2^$roundxlog)/1"|bc)
xh=$(echo "(0.6*2^$roundxlog)/1"|bc)
yl=$(echo "(0.4*2^$roundylog)/1"|bc)
yh=$(echo "(0.6*2^$roundylog)/1"|bc)
vclip if=magfft of=clipmagfft xl=$xl xh=$xh yl=$yl yh=$yh
vmath if=clipmagfft -mlog of=logmagfft
vifx if=logmagfft of=bytelogmagfft
vedge if=bytelogmagfft -d of=2channelbyteedges
vhoughl if=2channelbyteedges of=hough
vcc houghanalyze.c -o houghanalyze
eval $(houghanalyze if=hough)
echo theta is $theta
#created fhough to read the angle
#vcc fhough.c -o fhough
#eval $(fhough if=bytelogmagfft)
#echo theta is $theta
#todo: why does the fft image have so many vertical streaks?
vmath if=fft_$if -abs | vmath -mlog of=logrmfft
vfft if=logrmfft -i | vchan -mp | vchan c=1 |vifx of=cepstral
vcc closest0.c -o closest
eval $(closest if=cepstral)
echo range is $kernellength

rm clipmagfft
rm magged

