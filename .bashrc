# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

# don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
HISTCONTROL=ignoreboth

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=1000
HISTFILESIZE=2000

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# If set, the pattern "**" used in a pathname expansion context will
# match all files and zero or more directories and subdirectories.
#shopt -s globstar

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
    xterm-color|*-256color) color_prompt=yes;;
esac

# uncomment for a colored prompt, if the terminal has the capability; turned
# off by default to not distract the user: the focus in a terminal window
# should be on the output of commands, not on the prompt
#force_color_prompt=yes

if [ -n "$force_color_prompt" ]; then
    if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
	# We have color support; assume it's compliant with Ecma-48
	# (ISO/IEC-6429). (Lack of such support is extremely rare, and such
	# a case would tend to support setf rather than setaf.)
	color_prompt=yes
    else
	color_prompt=
    fi
fi

if [ "$color_prompt" = yes ]; then
    PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
else
    PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
fi
unset color_prompt force_color_prompt

# If this is an xterm set the title to user@host:dir
case "$TERM" in
xterm*|rxvt*)
    PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
    ;;
*)
    ;;
esac

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    #alias dir='dir --color=auto'
    #alias vdir='vdir --color=auto'

    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# colored GCC warnings and errors
#export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'

# some more ls aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

# Add an "alert" alias for long running commands.  Use like so:
#   sleep 10; alert
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

# Alias definitions.
# You may want to put all your additions into a separate file like
# ~/.bash_aliases, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.

if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi

parse_git_branch() {
git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/ (\1)/'
}
# shows hostname and file path
# export PS1="\u@\h \[\033[32m\]\w\[\033[33m\]\$(parse_git_branch)\[\033[00m\] $ "

# shows file path but no host name
export PS1="\[\033[32m\]\w\[\033[33m\]\$(parse_git_branch)\[\033[00m\] $ ";

# add golang path to PATH env var
export PATH=$PATH:/usr/local/go/bin

alias docker-ip='sudo docker inspect --format="{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}"'
alias docker-ids='docker ps -q' # docker ps | cut -d " " -f 1
alias docker-ps='docker ps --format "{{.ID}} --- {{.Names}}"'
alias docker-stop-all='docker stop $(docker ps -q) 2>/dev/null || echo "No containers running"'

# useful only for Mac OS Silicon M1, 
# still working but useless for the other platforms
docker() {
  if [[ `uname -m` == "arm64" ]] && [[ "$1" == "run" || "$1" == "build" || "$1" == "pull" ]]; then
    /usr/local/bin/docker run --platform linux/amd64 "${@:2}"
  else
     /usr/local/bin/docker "$@"
  fi
}

# executes a containerized version of maven so you don't have to install it to your computer.
# you need to have docker installed and running.
# append this snippet to your .bashrc/.zshrc/.bash_profile/.zsh_profile files.
# you can specify 'jdk8' or 'jdk11' as first argument to switch jdk.
# if not specified, jdk11 is the default.
# usage example: 
# /your/maven/project/directory - $ maven jdk8 clean install
# /your/maven/project/directory - $ maven clean package
maven() {
    mkdir -p $HOME/.m2/repository
    if [[ "$1" == "jdk8" ]]; then
        docker run --rm -v $PWD:/usr/src/app -v $HOME/.m2:/root/.m2 -w /usr/src/app maven:3.8-adoptopenjdk-8 mvn "${@:2}"
    elif [[ "$1" == "jdk11" ]]; then
        docker run --rm -v $PWD:/usr/src/app -v $HOME/.m2:/root/.m2 -w /usr/src/app maven:3.8-eclipse-temurin-11 mvn "${@:2}"
    elif [[ "$1" == "jdk6" ]]; then
        docker run --rm -v $PWD:/usr/src/app -v $HOME/.m2:/root/.m2 -w /usr/src/app maven:3.2-jdk-6 mvn "${@:2}"	
    else 
        docker run --rm -v $PWD:/usr/src/app -v $HOME/.m2:/root/.m2 -w /usr/src/app maven:3.8-eclipse-temurin-11 mvn "$@"
    fi
}

# shows you the tree of maven dependencies imported in your progect
mvn-tree() {
    mvn org.apache.maven.plugins:maven-dependency-plugin:2.8:tree
}
alias maven-tree='mvn-tree'
alias mvntree='mvn-tree'

# allows you to use go 17 without installing on your computer
# usage example: 
# /your/go/project/directory - $ golang run main.go
# /your/go/project/directory - $ golang test ./... -p 1 -count 1
# /your/go/project/directory - $ golang build .
golang() {
  docker run --rm -v $PWD:/usr/src/myapp -w /usr/src/myapp golang:1.17 go "$@"
}

# runs bash v5 not present on MacOSx
bash5() {
  docker run --rm -v $PWD:/usr/src/myapp -w /usr/src/myapp bash:5.1-alpine3.14 bash "$@"
}

# convers curl in wget
wget() {
   if [[ "$#" -ne 3 ]]; then 
      # wget <URL>
      curl -LO $1
   elif [[ "$2" == "-O" ]]; then
      # wget <URL> -O <filename> 
      curl -L -o $3 $1   
   fi
}

# exposes a port of your host on the internet through a generated public url.
# example: you have a web server lostening on your host on http://localhost:8080/myservice/hello
# to expose it you just have to write: $ localtunnel 8080
# in a few seconds the public url will be shown on your terminal, let's suppose is https://dull-firefox-10.loca.lt
# then anybody on the internet can reach the API running on your computer with:
# curl -H 'Bypass-Tunnel-Reminder: true' https://dull-firefox-10.loca.lt/myservice/hello 
localtunnel() {
   docker rm -f localtunnel &> /dev/null
   docker run -it -d --name localtunnel --network host efrecon/localtunnel --port $1 > /dev/null
   echo "Creating the connection. Please wait..."
   sleep 5
   export LOCAL_TUNNEL_URL=$(docker logs localtunnel | cut -d ' ' -f 4)
   echo "Your host port $1 is reachable to the public endpoint $LOCAL_TUNNEL_URL"
   echo 'You can use exported env variable $LOCAL_TUNNEL_URL'
}

# shorten the terminal location line to just the current line
# for that specific terminal process
alias shortpath='export PS1="\[\033[32m\]\W\[\033[33m\]\$(parse_git_branch)\[\033[00m\] $ "'
alias longpath='export PS1="\[\033[32m\]\w\[\033[33m\]\$(parse_git_branch)\[\033[00m\] $ "'

# show ram specs
alias memory='sudo lshw -short -C memory'

# show cpu specs
alias cpu='cat /proc/cpuinfo | less'

# show linux version
alias version='cat /proc/version'

# open project with intellij-idea-community installed with snap
# example: $ idea ./my-project-folder/pom.xml
alias idea='/snap/bin/intellij-idea-community'

# curl json with headers in the response
alias curl='curl -kLs' # allow insecure, follow redirects, hide progress
alias curlj='curl -s -D - -H "Content-Type: application/json;charset=utf-8"'

# look for a process with ps command and grep
alias grep-process='ps auxww | grep -v grep | grep' # <processname> or <PID>

# get PIDs list from process name
alias pid='pgrep' #<processname>

# get threads info about a single process
alias threads='top -H -p' #<PID>

# show env vars for a process given its PID
alias processenvs='function prenvs(){ cat /proc/$1/environ | tr "\000" "\n"; };prenvs'

# show file information
alias finfo='function finfofx(){ file $1; echo "dimension: "; du -chs $1 | head -1; echo "lines: "; wc -l $1; };finfofx'

# returns local LAN IP address
alias local-ip='hostname -I | cut -d " " -f 1'

# Example:
# subnetscan 192.168.122.1/24
subnetscan() {
  nmap -sn ${1} -oG - | awk '$4=="Status:" && $5=="Up" {print $2}'
}

# Scan subnet for available IPs
# Example:
# subnetfree 192.168.122.1/24
subnetfree() {
  nmap -v -sn -n ${1} -oG - | awk '/Status: Down/{print $2}'
}

# Quick network port scan of an IP
# Example:
# portscan 192.168.122.37
portscan() {
  nmap -oG -T4 -F ${1} | grep "\bopen\b"
}

alias ping='ping -c 4'

# grep string in entire directory (binary files excluded with the -I option)
alias grepdir='grep -nrI' #<string to be searched>

# show CPUs temperature (you must have sensors installed)
alias temp='sensors | head -20 | tail -9'

targz() {
   dirname=$1
   compressed="${dirname}.tar.gz"
   tar -czvf $compressed $dirname
   echo "${dirname}.tar.gz"
}

alias untargz='tar -xvzf'

extract () {
  if [ -f $1 ] ; then
      case $1 in
          *.tar.bz2)   tar xvjf $1    ;;
          *.tar.gz)    tar xvzf $1    ;;
          *.bz2)       bunzip2 $1     ;;
          *.rar)       rar x $1       ;;
          *.gz)        gunzip $1      ;;
          *.tar)       tar xvf $1     ;;
          *.tbz2)      tar xvjf $1    ;;
          *.tgz)       tar xvzf $1    ;;
          *.zip)       unzip $1       ;;
          *.Z)         uncompress $1  ;;
          *.7z)        7z x $1        ;;
          *)           echo "don't know how to extract '$1'..." ;;
      esac
  else
      echo "'$1' is not a valid file!"
  fi
}

alias mkdir='mkdir -p'

alias cp='cp -r'

# echo 345 | copy | paste
alias copy='xclip'
alias paste='xclip -o'

# inline functions (put spaces close to {}, put ; at the end of each command)
now() { date +"%A, %b %d, %Y %I:%M %p"; }


function backup-and-modify() {
    echo "You are making a copy of $1 before you open it. Press enter to continue."
    read nul
    cp $1 $1.bak
    nano $1
}

# substitute all occurrencies in a directory
# usage: escape special chars (like dot "."). For example
# $  substall 'env\.' 'updated-env\.'
substall() { grep -nrI "$1" | cut -f 1 -d ":" | sort | uniq |  xargs -I {} sed -i "s/$1/$2/g" {}; }

# finds all files where a string occurres (no binary files included). Rembember to escape dots like above
findallfiles() { grep -nrI "$1" | cut -f 1 -d ":" | sort | uniq; }

# delete line from file where an occurrency is found
# usage:
# $ deleteline 'env\.Port' myfile.csv
deleteline() { sed "/$1/d" -i $2; } 

repeatfn() { while read line; do $1; done < "$2"; }

# let you open a file with its default program. Ex. Open current folder: $ open .
# FOR MAC OS is not necessary
# alias open='xdg-open'
case "$OSTYPE" in
   cygwin*)
      alias open="cmd /c start"
      ;;
   linux*)
      alias open="xdg-open"
      ;;
   darwin*)
      # alias open="open" not necessary for mac
      ;;
esac

# launch a command into another terminal.
# Example:
# new-term-exec 'ls -a; echo "hello"'
# new-term-exec ./script.sh
new-term-exec() { gnome-terminal -- bash -c "$1; exec bash"; }

# inline if
# if [ $(git stash list | grep $STASH_NAME | cut -f 1 -d ":" | head -1) ]; then echo "true"; else echo "false"; fi
iff() { if [ $0 ]; then $1; else $2; fi; }

# usage: random-string 10
alias random-string='tr -dc A-Za-z0-9 </dev/urandom | head -c'

alias c='clear'
alias d='docker'
alias g='git'
alias k='kubectl'

alias gut='echo "`tput setaf 5``tput bold`You probabily meant git`tput sgr0`"; git'
alias gi='echo "`tput setaf 5``tput bold`You probabily meant git`tput sgr0`"; git'

# let you refresh the current terminal when you update .bashrc file adding aliases or functions
alias bashrc='source ~/.bashrc'
alias zshrc='source ~/.zshrc'

# just an exercise to selectively delete files in a Java project
go-delete-tests() {
    
    # on a custom branch X - let's save the staged and unstaged changes giving a random name
    STASH_NAME=$(tr -dc A-Za-z0-9 </dev/urandom | head -c 10)
    git stash push -m $STASH_NAME -u
    
    # let's fetch all changes from the remote branches and tags
    git fetch -tp
    
    # let's move to with-no-tests branch and reset it to origin/with-no-tests if exists; else it creates a new one
    git checkout -B with-no-tests
    
    # let's force with-no-tests to origin/master
    git reset --hard origin/master
    
    # delete any file terminating with '_test.go'
    find . -name \*_test.go -type f -delete
    
    # commit and push force on origin/with-no-tests branch
    git commit -am "Removed test files"
    git push -f origin with-no-tests
    
    # checkout back on previous branch
    git checkout -
    
    # get stash id from the stash name
    STASH_ID=$(git stash list | grep $STASH_NAME | cut -f 1 -d ":" | head -1)
    
    # if stash exists, apply it
    if [[ $STASH_ID ]]; then
        echo "reapplying stash $STASH_ID - $STASH_NAME"
        git stash apply $STASH_ID
    else
        echo "no stashed changes found"  
    fi
}

# just an exercise to selectively delete files in a Java project
delete-java-tests() {
     # on a custom branch X - let's save the staged and unstaged changes giving a random name
    STASH_NAME=$(tr -dc A-Za-z0-9 </dev/urandom | head -c 10)
    git stash push -m $STASH_NAME -u
    
    # let's fetch all changes from the remote branches and tags
    git fetch -tp
    
    # let's move to with-no-tests branch and reset it to origin/with-no-tests if exists; else it creates a new one
    git checkout -B with-no-tests
    
    # let's force with-no-tests to origin/master
    git reset --hard origin/master
    
    # delete any test file and folder
    find . -type d -name \*test* -prune -exec rm -rf {} \;
    find . -name \*test* -type f -delete
    
    # commit and push force on origin/with-no-tests branch
    git commit -am "Removed tests"
    git push -f origin with-no-tests
    
    # checkout back on previous branch
    git checkout -
    
    # get stash id from the stash name
    STASH_ID=$(git stash list | grep $STASH_NAME | cut -f 1 -d ":" | head -1)
    
    # if stash exists, apply it
    if [[ $STASH_ID ]]; then
        echo "reapplying stash $STASH_ID - $STASH_NAME"
        git stash apply $STASH_ID
    else
        echo "no stashed changes found"  
    fi
}

# split each line with a separator and get the specified column.
# Usage: 
#   $ split-get ':' 2 myfile.csv
#   $ cat myfile | split-get ':' 2
split-get() {
   if [[ "$#" == 3 ]]; then
     cut -f $2 -d $1 $3
   else
     cut -f $2 -d $1 /dev/stdin
   fi          
}

# cat "hello how are you?" | spl -d ' ' -p 0 
# > hello
# array=`spl --file myfile.txt --delimiter ':'` && echo "${array[2]}"
# > re
spl() {
    index=0
    dindex=-10
    pindex=-10
    findex=-10

    for var in "$@"
    do
       if [[ "$index" == $(($dindex+1)) ]]; then
	  delimiter=$var
       elif [[ "$index" == $(($pindex+1)) ]]; then
	  position=$var   
       elif [[ "$index" == $(($findex+1)) ]]; then
          filename=$var   
       elif [[ "$var" == "-d" || "$var" == "--delimiter" ]]; then
	  dindex=$index
       elif [[ "$var" == "-p" || "$var" == "--position" ]]; then
          pindex=$index  
       elif [[ "$var" == "-f" || "$var" == "--file" ]]; then
	  findex=$index    
       elif [[ "$var" == "-h" || "$var" == "--help" ]]; then
          echo "Usage:"
	  echo "spl -d <delimeter> -p <position-from-zero> -f <filename>"
          echo "or"
          echo "spl --delimeter <delimeter> --position <position-from-zero> --file <filename>"
          echo "or"
          echo "cat <filename> | spl --delimeter <delimeter> --position <position-from-zero>"
          echo "or to have the entire array"
          echo "spl -d <delimeter> -f <filename>"  
          return 0    
       fi
       index=$(($index+1)) 
    done

    if [[ -z "$delimiter" ]]; then
        echo "No delimiter specified with -d or --delimeter flag"
        return 1
    fi    

    if [[ -z "$filename" ]]; then
       filecontent=$( < /dev/stdin )
    else
       filecontent=$(cat $filename)
    fi

    splitted=(${filecontent//$delimiter/ })
   
    if [[ -z "$position" ]]; then
       $splitted
       return 0
    fi
	
    echo "${splitted[$position]}"
}

# prints from line x to line y of a given file.
# Usage:
# $ middle 11 15 file.txt
# $ cat file.txt | middle 11 15
middle() { 
   if [[ "$#" == 3 ]]; then
     head -$2 $3 | tail -$(($2-$1+1))
   else
     head -$2 /dev/stdin | tail -$[$2 - $1 + 1]
   fi
}
export -f middle

show-me() {
    NAME=$1
    FILE=$2
    LINE=$(grep $NAME $FILE -c)
    START=$(($LINE-10))
    if [[ "$START" -lt 0 ]]; then
        START=1
    fi
    echo $START    
    END=$(($LINE+10))
    echo $END
    middle 90 100 $FILE
}
export -f show-me

# executes locally a remote bash script given its URL
# es. : $ remote-bash https://github.com/myaccount/myrepo/myscript.sh
remote-bash() {
   if [[ "$#" == 1 ]]; then
     script_url=$1   
     curl -s $script_url | bash
   else
     echo "No valid script url provided"
     return 1
   fi
}

is-arm() {
    dpkg --print-architecture
}

is-amd() {
    dpkg --print-architecture
}

k8s-apigroups() {
    kubectl api-resources -o wide
}

# moves a bash script to /usr/local/bin to let you recall directly without using ./<scriptname>.
# it allows you to specify an alias:
# example:
# $ executable myscript.sh
# $ executable myscript.sh myscript
executable() {
  if [[ "$#" == 1 ]]; then
     chmod +x $1
     sudo mv $1 /usr/local/bin
  elif [[ "$#" == 2 ]]; then 
     mv $1 $2 
     chmod +x $2
     sudo mv $2 /usr/local/bin
  else 
     echo "Invalid command format: specify file and optional alias"
     exit 1
  fi   
}


news() {
    curl https://api.nytimes.com/svc/mostpopular/v2/emailed/1.json?api-key=LGKGUSF6JjCctvSIOLq7LPCaxSoALvEY \
   | jq '.results[] | "\nTITLE: " + .title + "\nABSTRACT: " + .abstract' | xargs -I {} printf "{}\n\n"
}

# show latest file
alias latest='ls -t | head -1'


# returns a substring: Usage: $ substr "ciao a tutti!" 1 3  => iao
substr() {
    
    str=$0
    start=$1
    length=$2

    echo ${str:start:length}
}

alias ip='zenity --info --text=$(hostname -I | cut -d " " -f 1)'

# empty the content of a file:
# usage: clean-file 2021-august.log
clean-file() {
    cat /dev/null > $1
}

alias mvndebug='~/workspace/apache-maven-3.8.3-bin/bin/mvnDebug.cmd' # clean install

# shows all the aliases defined in .bashrc
alias aliases='grep "alias " ~/.bashrc'

# returns the exposed port for a k8s pod
# $ kube-pod-port mongo-75f6385hf-67dgs4
# 27017
kube-pod-port() {
   kubectl get pod $1 --template='{{(index (index .spec.containers 0).ports 0).containerPort}}{{"\n"}}'
}
# later you can port forward on the node:
# $ kubectl port-forward mongo-75f6385hf-67dgs4 28015:27017

# returns all the pods deployed on a given k8s node:
# $ kube-node-pods k3d-demo-agent-0
kube-node-pods() {
    kubectl get pods --all-namespaces -o wide --field-selector spec.nodeName=$1
}

# for mac
#alias code='/Applications/Visual\ Studio\ Code.app/Contents/Resources/app/bin/code'

# ~/.gitconfig ALIASES
#[alias]
#    ls = "!f() { git log $1 --pretty=format:\"%C(yellow)%h%Cred%d\\\\ %Creset%s%Cgreen\\\\ [%ae,%ar]\" --decorate --graph; }; f"
#    lsi = log --pretty=format:\"%C(yellow)%h%Cred%d\\\\ %Creset%s%Cgreen\\\\ [%ae,%ar]\" --decorate --graph | head -5
#    lasttag = "!f(){git describe --tags `git rev-list --tags --max-count=1`};f"
#    last-tag = !git fetch -tp && git describe --tags
#    bl = blame -c --date=short
#    CHECKOUT = "findallfiles 'Test'() { git checkout  2>/dev/null || git checkout -b ; }; f"
#    switch = "!f() { git checkout $1 2>/dev/null || git checkout -b $1; }; f"
#    switch2 = "!f() { git checkout $1 2>/dev/null || git checkout -b $1; }; f"
#    commits-behind = "!f() { git fetch -tp > /dev/null 2>&1; git log --oneline $(git branch --show-current)..$1; }; f"
#    branch-name = branch --show-current
#    delete-branch = "!f() { if [ \"$#\" == 0 ]; then echo \"You must specify the branch to be deleted!\"; elif [ \"$#\" == 1 ]; then echo \"git branch -D $1\"; elif [ \"$1\" == \"-a\" ]; then echo \"git branch -D $2 && git push origin --delete $2\"; elif [ \"$1\" == \"-r\" ]; then echo \"git push origin --delete $2\"; else echo \"git branch -D $2\"; fi; }; f"
#    get-status = "!f() { if [[ \"$1\" == \"ciao\" ]]; then echo \"mi hai salutato!\"; fi; git fetch -tp; git status; echo \"$1\"; }; f"
#    wip = "!f() { git stash save $1 -u ; }; f"
