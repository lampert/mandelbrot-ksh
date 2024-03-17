#!/usr/bin/env ksh
# generate mandelbrot to terminal, just for fun

typeset LIMIT=500
typeset xmax=$(( $(tput cols)  ))  # number of columns on screen
typeset ymax=$(( $(tput lines)  )) # number of rows on screen

typeset ac=${1:-.21} # default parameters that show a nice pic
typeset bc=${2:-.50}
typeset si=${3:-.2}

# generate mandelbrot coordinates
function .sh.math.mandel a b
{
    integer n=$LIMIT
    float nadj=$(( 230.0 / LIMIT ))
    float x=0 y=0 xx zz
    while ((n>0));do
        (( zz=(x*x)-(y*y) ))
        (( zz>=4 )) && break
        (( xx=zz+a ))
        (( y=2*x*y+b ))
        (( x=xx ))
        (( --n ))
    done
    (( .sh.value=int(n*nadj+16) ))
}

#echo "xmax=$xmax ymax=$ymax ac=$ac bc=$bc si=$si; as=$as gx=%gx gy=$gy"
#change fg    print -n "[38;5;${color}m"
#change bg    print -n "[48;5;${color}m"
typeset resetattr="[0m"

(( as=xmax/ymax ))
(( gx=si/xmax ))
(( gy=si/(as*ymax) ))


# temporary files to generate in parallel
trap "rm /tmp/mand-$$.*.out" 0

typeset a b x1 y1 m0 m1
for (( b=bc, y1=0; y1<ymax; b+=gy+gy, y1++ ));do
    output=$(printf "/tmp/mand-$$.%06d.out" $y1)
    (
        for (( a=ac, x1=0; x1<xmax; a+=gx, x1++ ));do
            (( m0=mandel(a,b) ))
            (( m1=mandel(a,b+gy) ))
            # set bg and fg color (upper half and lower half) and draw 2 pixels
            print -n "[38;5;${m1}m[48;5;${m0}m▅" 
        done
        print $resetattr
    ) >$output &
done
wait
cat /tmp/mand-$$.*.out

