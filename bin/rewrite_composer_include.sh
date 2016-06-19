if [ $# -ne 2 ];then
    echo "Not enough arguments supplied; cannot determine latest composer include file" ;
    exit 1 ;
fi

PUBLIC=$1
GIT_REPOS=$2

sed -re "s#${GIT_REPOS}([^\"]+)#https://github.com\1.git#g" --in-place $(ls -t ${PUBLIC}/include | head -n 1)
