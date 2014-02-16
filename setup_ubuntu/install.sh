#!/bin/bash
# Install ubuntu base

. install.dist.cfg

sortie() {
    rc=$1
    test $rc -eq 0  && echo "Install completed." || echo "Install error [$rc]"
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
    #run sudo 'echo "deb http://archive.ubuntu.com/ubuntu precise main universe" >> /etc/apt/sources.list'
    run sudo apt-get update 
    run sudo apt-get upgrade -y 
    run sudo apt-get dist-upgrade
    install_package zsh curl git-core
    install_package language-pack-fr
    trace " --> packages OK"
}

install_package() {
    run sudo apt-get install -y $*
}

create_users() {
    trace "Creating all users... ${!USERS[*]}"
    for user in ${!USERS[*]}; do
        trace "Create user : $user"
        id $user >/dev/null || create_user.sh $user ${USERS[${user}]}
    done
}

create_usersser() {
    user=$1
    ssh_key=$2
    trace "Create user : $user"
    run sudo useradd $user -d /home/$user -m -s /bin/zsh
    run sudo mkdir -p /home/$user/.ssh
    trace " Install SSH key $ssh_key"
    run sudo touch /home/$user/.ssh/authorized_key
    run sudo chmod 777 /home/$user/.ssh/authorized_key
    curl $ssh_key > /home/$user/.ssh/authorized_key
    run sudo chmod 600 /home/$user/.ssh/authorized_key
    run sudo chmod 700 /home/$user/.ssh
    run sudo chmod 750 /home/$user
    run sudo chown -R $user:$user /home/$user
    trace " --> User $user created"
    #Install oh-my-zsh
    sudo su $user -c 'curl -L https://github.com/robbyrussell/oh-my-zsh/raw/master/tools/install.sh | sh'
}


trace "Installation du minimal vital sur $os_version serveur"
test_os
#install_packages
create_users
sortie 0
