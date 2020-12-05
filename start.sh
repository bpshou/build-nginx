#!/bin/bash

cd $(dirname $0)

if [ -d "../resource/nginx/" ];then
    cp -r ../resource/nginx/nginx-1.18.0.tar.gz ./
    cp -r ../resource/nginx/openssl-1.1.1g.tar.gz ./
    cp -r ../resource/nginx/zlib-1.2.11.tar.gz ./
    cp -r ../resource/nginx/pcre-8.44.tar.gz ./
fi
if [ ! -f "nginx-1.18.0.tar.gz" ]; then
    curl -L http://nginx.org/download/nginx-1.18.0.tar.gz -o nginx-1.18.0.tar.gz
fi
if [ ! -f "openssl-1.1.1g.tar.gz" ]; then
    curl -L https://www.openssl.org/source/openssl-1.1.1g.tar.gz -o openssl-1.1.1g.tar.gz
fi
if [ ! -f "zlib-1.2.11.tar.gz" ]; then
    curl -L http://www.zlib.net/zlib-1.2.11.tar.gz -o zlib-1.2.11.tar.gz
fi
if [ ! -f "pcre-8.44.tar.gz" ]; then
    curl -L https://ftp.pcre.org/pub/pcre/pcre-8.44.tar.gz -o pcre-8.44.tar.gz
fi

if [ ! -n "$1" ]; then
    los=alpine
else
    los=$1
fi

docker run -itd --name $los $los
docker cp ./nginx-1.18.0.tar.gz $los:/home
docker cp ./openssl-1.1.1g.tar.gz $los:/home
docker cp ./zlib-1.2.11.tar.gz $los:/home
docker cp ./pcre-8.44.tar.gz $los:/home
docker cp ./nginx.sh $los:/home
docker cp ./add-nginx.sh $los:/home
docker exec -it $los sh /home/add-nginx.sh
docker cp $los:/home/nginx ./

tar -zcvf nginx.tar.gz nginx

