#!/bin/bash

# 获取linux发行版本
release () {
    lsb_dist=""
    # redhat
    if [ -r /etc/redhat-release ]; then
        lsb_dist="centos";
    fi
    # ubuntu
    if [ -r /etc/lsb-release ]; then
        lsb_dist="ubuntu";
    fi
    # alpine
    if [ -r /etc/alpine-release ]; then
        lsb_dist="alpine";
    fi
    echo "$lsb_dist"
}

lsb_dist=$( release )
# 包管理器
if [ "$lsb_dist" = "centos" ]; then
    # 添加nginx用户
    groupadd --system --gid 101 nginx
    useradd --system -g nginx --no-create-home --home /nonexistent --comment "nginx user" --shell /bin/false --uid 101 nginx
    # 安装依赖
    yum -y install curl gcc-c++ make
    # 复制依赖库
    mkdir -p /home/lib
elif [ "$lsb_dist" = "ubuntu" ]; then
    # 添加nginx用户
    addgroup --system --gid 101 nginx
    adduser --system --disabled-login --ingroup nginx --no-create-home --home /nonexistent --gecos "nginx user" --shell /bin/false --uid 101 nginx
    # 安装依赖
    apt-get update && apt-get -y install curl build-essential autoconf
    # 复制依赖库
    mkdir -p /home/lib
    cp -r /lib/x86_64-linux-gnu/libdl.so.2 /home/lib
    cp -r /lib/x86_64-linux-gnu/libpthread.so.0 /home/lib
    cp -r /lib/x86_64-linux-gnu/libcrypt.so.1 /home/lib
    cp -r /lib/x86_64-linux-gnu/libc.so.6 /home/lib
    # cp -r /lib64/ld-linux-x86-64.so.2 /home/lib
    # 依赖库实体so文件
    cp -r /lib/x86_64-linux-gnu/libc-2.31.so /home/lib
    cp -r /lib/x86_64-linux-gnu/libcrypt.so.1.1.0 /home/lib
    cp -r /lib/x86_64-linux-gnu/libdl-2.31.so /home/lib
    cp -r /lib/x86_64-linux-gnu/libpthread-2.31.so /home/lib
    cp -r /lib/x86_64-linux-gnu/ld-2.31.so /home/lib
    cd /home/lib && ln -s ld-2.31.so ld-linux-x86-64.so.2
elif [ "$lsb_dist" = "alpine" ]; then
    # 添加nginx用户
    addgroup -g 101 -S nginx
    adduser -S -D -H -u 101 -h /var/cache/nginx -s /sbin/nologin -G nginx -g nginx nginx
    # 安装依赖
    apk add --no-cache --virtual .build curl gcc libc-dev make openssl-dev pcre-dev zlib-dev linux-headers libxslt-dev gd-dev geoip-dev perl-dev libedit-dev mercurial bash alpine-sdk findutils
    # 复制依赖库
    mkdir -p /home/lib
    cp -r /lib/ld-musl-x86_64.so.1 /home/lib
else
    echo 'error: unknow system'
    exit 0;
fi


# curl -L http://nginx.org/download/nginx-1.18.0.tar.gz -o nginx-1.18.0.tar.gz && tar -zxvf nginx-1.18.0.tar.gz
# curl -L https://www.openssl.org/source/openssl-1.1.1g.tar.gz -o openssl-1.1.1g.tar.gz && tar -zxvf openssl-1.1.1g.tar.gz
# curl -L http://www.zlib.net/zlib-1.2.11.tar.gz -o zlib-1.2.11.tar.gz && tar -zxvf zlib-1.2.11.tar.gz
# curl -L https://ftp.pcre.org/pub/pcre/pcre-8.44.tar.gz -o pcre-8.44.tar.gz && tar -zxvf pcre-8.44.tar.gz

tar -zxvf /home/nginx-1.18.0.tar.gz -C /home
tar -zxvf /home/openssl-1.1.1g.tar.gz -C /home
tar -zxvf /home/zlib-1.2.11.tar.gz -C /home
tar -zxvf /home/pcre-8.44.tar.gz -C /home

cd /home/pcre-8.44 && autoreconf -vfi
cd /home/nginx-1.18.0

# nginx configure
./configure \
--prefix=.. \
--sbin-path=sbin/nginx \
--modules-path=modules \
--conf-path=conf/nginx.conf \
--error-log-path=logs/error.log \
--http-log-path=logs/access.log \
--pid-path=run/nginx.pid \
--lock-path=run/nginx.lock \
--http-client-body-temp-path=temp/client_temp \
--http-proxy-temp-path=temp/proxy_temp \
--http-fastcgi-temp-path=temp/fastcgi_temp \
--http-uwsgi-temp-path=temp/uwsgi_temp \
--http-scgi-temp-path=temp/scgi_temp \
--user=nginx \
--group=nginx \
--with-compat \
--with-file-aio \
--with-threads \
--with-http_addition_module \
--with-http_auth_request_module \
--with-http_dav_module \
--with-http_flv_module \
--with-http_gunzip_module \
--with-http_gzip_static_module \
--with-http_mp4_module \
--with-http_random_index_module \
--with-http_realip_module \
--with-http_secure_link_module \
--with-http_slice_module \
--with-http_ssl_module \
--with-http_stub_status_module \
--with-http_sub_module \
--with-http_v2_module \
--with-mail \
--with-mail_ssl_module \
--with-stream \
--with-stream_realip_module \
--with-stream_ssl_module \
--with-stream_ssl_preread_module \
--with-cc-opt='-Os -fomit-frame-pointer -Wno-error' \
--with-ld-opt='-Wl,--as-needed,-rpath,../lib -L../lib -lstdc++ -ldl' \
--with-pcre=../pcre-8.44 \
--with-openssl=../openssl-1.1.1g \
--with-zlib=../zlib-1.2.11

# 变更参数
# --with-cc-opt='-Os -fomit-frame-pointer'
# --with-ld-opt=-Wl,--as-needed \

make && make install

if [ $? = 0 ]; then
    rm -rf /home/nginx-1.18.0* /home/openssl-1.1.1g* /home/pcre-8.44* /home/zlib-1.2.11* /home/add-nginx.sh
    # 创建收纳相关信息
    mkdir -p /home/temp /nginx && mv /home/* /nginx && mv /nginx /home/

    echo 'nginx build success'
else
    echo 'nginx build error'
    exit 1
fi

