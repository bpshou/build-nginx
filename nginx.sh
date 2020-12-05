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

# 版本
lsb_dist=$( release )

exiUser=$(grep -w nginx /etc/passwd)
if [ ! -n "$exiUser" ]; then
    if [ "$lsb_dist" = "centos" ]; then
        # 添加nginx用户
        groupadd --system --gid 101 nginx
        useradd --system -g nginx --no-create-home --home /nonexistent --comment "nginx user" --shell /bin/false --uid 101 nginx
    elif [ "$lsb_dist" = "ubuntu" ]; then
        # 添加nginx用户
        addgroup --system --gid 101 nginx
        adduser --system --disabled-login --ingroup nginx --no-create-home --home /nonexistent --gecos "nginx user" --shell /bin/false --uid 101 nginx
    elif [ "$lsb_dist" = "alpine" ]; then
        # 添加nginx用户
        addgroup -g 101 -S nginx
        adduser -S -D -H -u 101 -h /var/cache/nginx -s /sbin/nologin -G nginx -g nginx nginx
    else
        echo 'error: unknow system'
        exit 0;
    fi
fi

cd $(dirname $0)/sbin
exec ./nginx "$@"

