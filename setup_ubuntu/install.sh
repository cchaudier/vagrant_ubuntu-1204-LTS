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
    echo "==[cmd : $*i]=="
    $* || sortie 1
}

test_os() {
    trace "Test OS version"
    grep "$os_version" /etc/issue >/dev/null|| (trace "OS not $os_version" && sortie 1)
    trace " --> Os OK"

}

install_packages(){
    trace "Installation packages"
    run sudo 'echo "deb http://archive.ubuntu.com/ubuntu precise main universe" > /etc/apt/sources.list'
    run sudo apt-get update 
    run sudo apt-get upgrade -y 
    run sudo apt-get dist-upgrade
    run sudo apt-get install -y zsh curl git-core
    trace " --> packages OK"
}

create_users() {
    for user in $users; do
        create_user $user
    done
}

create_user() {
    user=$1
    trace "Create user : $1user"
    id $user || run sudo adduser $user --disabled-password
}

trace "Installation du minimal vital sur $os_version serveur"
test_os
install_packages
create_users
sortie 0
