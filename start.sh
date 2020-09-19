#!/bin/bash

curl -L http://nginx.org/download/nginx-1.18.0.tar.gz -o nginx-1.18.0.tar.gz
curl -L https://www.openssl.org/source/openssl-1.1.1g.tar.gz -o openssl-1.1.1g.tar.gz
curl -L http://www.zlib.net/zlib-1.2.11.tar.gz -o zlib-1.2.11.tar.gz
curl -L https://ftp.pcre.org/pub/pcre/pcre-8.44.tar.gz -o pcre-8.44.tar.gz

if [ ! -n "$1" ]; then
    los=alpine
else
    los=$1
fi

docker run -itd --name $los $los sh
docker cp ./nginx-1.18.0.tar.gz $los:/home
docker cp ./openssl-1.1.1g.tar.gz $los:/home
docker cp ./zlib-1.2.11.tar.gz $los:/home
docker cp ./pcre-8.44.tar.gz $los:/home
docker cp ./nginx.sh $los:/home
docker cp ./add-nginx.sh $los:/home
docker exec -it $los sh /home/add-nginx.sh

