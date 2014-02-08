#!/bin/bash
# Install ubuntu base

. install.dist.cfg

sortie() {
    rc=$1
    test $rc -eq 0  && echo "Install completted." || echo "Install error [$rc]"
    exit $rc
}

trace() {
    echo "$(date "+%Y-%m-%d %H:%M:%S") | $*"
}

run() {
    echo "cmd : $*"
    $* || sortie 1
}

test_os() {
    trace "Test OS version"
    grep "$os_version" /etc/issue >/dev/null|| (trace "OS not $os_version" && sortie 1)
    trace "Os ok"

}

install_packages(){
    trace "Installation packages"
    run echo "deb http://archive.ubuntu.com/ubuntu precise main universe" > /etc/apt/sources.list
    run apt-get update && apt-get upgrade -y && apt-get dist-upgrade
    run apt-get install -y zsh curl git-core
}

create_users() {
    for user in $users; do
        create_user $user
    done
}

create_user() {
    user=$1
    trace "Create user : $1user"
    id $user || run adduser $user --disabled-password
}

trace "Installation du minimal vital sur $os_version serveur"

test_os
install_packages
create_users
sortie 0
