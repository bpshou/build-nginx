#!/bin/bash

cd $(dirname $0)

if [ -d "./src/" ];then
    mkdir -p src
fi

if [ -d "../resource/nginx/" ];then
    cp -r ../resource/nginx/nginx-1.18.0.tar.gz ./src/
    cp -r ../resource/nginx/openssl-1.1.1g.tar.gz ./src/
    cp -r ../resource/nginx/zlib-1.2.11.tar.gz ./src/
    cp -r ../resource/nginx/pcre-8.44.tar.gz ./src/
fi

if [ ! -f "./src/nginx-1.18.0.tar.gz" ]; then
    curl -L http://nginx.org/download/nginx-1.18.0.tar.gz -o ./src/nginx-1.18.0.tar.gz
fi
if [ ! -f "./src/openssl-1.1.1g.tar.gz" ]; then
    curl -L https://www.openssl.org/source/openssl-1.1.1g.tar.gz -o ./src/openssl-1.1.1g.tar.gz
fi
if [ ! -f "./src/zlib-1.2.11.tar.gz" ]; then
    curl -L http://www.zlib.net/zlib-1.2.11.tar.gz -o ./src/zlib-1.2.11.tar.gz
fi
if [ ! -f "./src/pcre-8.44.tar.gz" ]; then
    curl -L https://ftp.pcre.org/pub/pcre/pcre-8.44.tar.gz -o ./src/pcre-8.44.tar.gz
fi
# add module rtmp
if [ "$3" = "rtmp" ]; then
    if [ ! -d "./src/nginx-rtmp-module" ]; then
        echo "add module rtmp"
        git clone https://github.com/arut/nginx-rtmp-module.git ./src/nginx-rtmp-module
    fi
fi 

if [ ! -n "$1" ]; then
    los=alpine
else
    los=$1
fi

if [ ! -n "$2" ]; then
    tag=latest
else
    tag=$2
fi

# run container
losIsRun=`docker ps -a | grep -Eio $los | uniq`
if [ ! -z "$losIsRun" ]; then
    docker rm -f $los
fi
docker run -itd --name $los $los:$tag
docker cp ./build-nginx.sh $los:/home
docker cp ./src $los:/home

# build nginx
docker exec -it $los sh /home/build-nginx.sh
docker cp $los:/home/nginx ./

# pack nginx
if [ -d "nginx" ]; then
    tar -zcvf nginx.tar.gz nginx
fi

