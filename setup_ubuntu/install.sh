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
    echo "==[cmd : $*]=="
    $* || sortie 1
}

test_os() {
    trace "Test OS version"
    grep "$os_version" /etc/issue >/dev/null|| (trace "OS not $os_version" && sortie 1)
    trace " --> Os OK"

}

install_packages(){
    trace "Installation packages"
    run sudo 'echo "deb http://archive.ubuntu.com/ubuntu precise main universe" >> /etc/apt/sources.list'
    run sudo apt-get update 
    run sudo apt-get upgrade -y 
    run sudo apt-get dist-upgrade
    run sudo apt-get install -y zsh curl git-core
    trace " --> packages OK"
}

create_users() {
    for user in ${!USERS[*]}; do
        create_user $user ${USERS[${user}]}
    done
}

create_user() {
    user=$1
    ssh_key=$2
    trace "Create user : $user"
    id $user || run sudo adduser $user --disabled-password --home /home/$user --shell zsh
    run sudo mkdir -p /home/$user/.ssh
    trace " Install SSH key $ssh_key"
    run sudo touch /home/$user/.ssh/authorized_key
    run sudo chmod 777 /home/$user/.ssh/authorized_key
    curl $ssh_key > /home/$user/.ssh/authorized_key
    run sudo chmod 600 /home/$user/.ssh/authorized_key
    run sudo chmod 700 /home/$user/.ssh
    run sudo chmod 750 /home/$user
    run sudo chown -R $user:$user /home/$user

}

trace "Installation du minimal vital sur $os_version serveur"
test_os
install_packages
create_users
sortie 0
