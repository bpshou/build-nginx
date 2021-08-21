#!/bin/bash

exiUser=$(grep -w nginx /etc/passwd)
# 检查用户是否存在并创建
if [ ! -n "$exiUser" ]; then
    # 添加nginx用户
    # 获取linux发行版本
    Release=$(grep -Eio "Ubuntu|Debian" /etc/issue)
    # alpine
    if [ -r /etc/alpine-release ]; then
        addgroup -g 101 -S nginx
        adduser -S -D -H -u 101 -h /var/cache/nginx -s /sbin/nologin -G nginx -g nginx nginx
    # Debian & Ubuntu
    elif [ -n "$Release" ]; then
        addgroup --system --gid 101 nginx
        adduser --system --disabled-login --ingroup nginx --no-create-home --gecos "nginx user" --shell /bin/false --uid 101 nginx
    # centos
    elif [ -r /etc/redhat-release ]; then
        groupadd --system --gid 101 nginx
        useradd --system -g nginx --no-create-home --home /nonexistent --comment "nginx user" --shell /bin/false --uid 101 nginx
    else
        echo 'error: Unknow system, Cannot create nginx user'
        exit 1;
    fi
fi

cd $(dirname $0)/sbin
exec ./nginx "$@"

