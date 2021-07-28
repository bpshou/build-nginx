#!/bin/bash

# 获取linux发行版本
release () {
    lsb_dist=""
    # alpine
    if [ -r /etc/alpine-release ]; then
        lsb_dist="alpine";
    fi
    # debian
    if [ -r /etc/debian_version ]; then
        lsb_dist="debian";
    fi
    # ubuntu
    if [ -r /etc/lsb-release ]; then
        lsb_dist="ubuntu";
    fi
    # redhat
    if [ -r /etc/redhat-release ]; then
        lsb_dist="centos";
    fi
    echo "$lsb_dist"
}

lsb_dist=$( release )


exiUser=$(grep -w nginx /etc/passwd)
# 检查用户是否存在并创建
if [ ! -n "$exiUser" ]; then
    # 添加nginx用户
    if [ "$lsb_dist" = "alpine" ]; then
        addgroup -g 101 -S nginx
        adduser -S -D -H -u 101 -h /var/cache/nginx -s /sbin/nologin -G nginx -g nginx nginx
    elif [ "$lsb_dist" = "debian" ]; then
        addgroup --system --gid 101 nginx
        adduser --system --disabled-login --ingroup nginx --no-create-home --gecos "nginx user" --shell /bin/false --uid 101 nginx
    elif [ "$lsb_dist" = "ubuntu" ]; then
        addgroup --system --gid 101 nginx
        adduser --system --disabled-login --ingroup nginx --no-create-home --home /nonexistent --gecos "nginx user" --shell /bin/false --uid 101 nginx
    elif [ "$lsb_dist" = "centos" ]; then
        groupadd --system --gid 101 nginx
        useradd --system -g nginx --no-create-home --home /nonexistent --comment "nginx user" --shell /bin/false --uid 101 nginx
    else
        echo 'error: Unknow system, Cannot create nginx user'
        exit 1;
    fi
fi

cd $(dirname $0)/sbin
exec ./nginx "$@"

