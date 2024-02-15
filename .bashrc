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
alias folders='ls -d */'

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
export PS1="\[\033[32m\]\w\[\033[36m\]\$(parse_git_branch)\[\033[34m\] $\[\033[00m\] ";

# exporting go env vars and update the $PATH
# by exporting these, you can use any binary you install in $GOPATH/bin, for example with:
# $ go get github.com/go-delve/delve/cmd/dlv
# you can recall directly 'dlv' command through your terminal:
# $ dlv version
# 'which go' returns /usr/local/go/bin/go
export GOROOT=$(go env GOROOT) # /usr/local/go
export GOPATH=$(go env GOPATH) # /Users/alessandro.argentieri/go
export PATH=$GOPATH/bin:$PATH
export PATH=$PATH:$GOROOT/bin

# needs: go install github.com/vc60er/deptree@latest
# shows the golang project dependency tree:
# usage:
# $ gotree 4 # max depth: 4
alias gotree='go mod graph | deptree -d'

alias uninstall-go='rm -rvf `go env GOROOT`'

# upgrades the go version downloading the new version with go itself
# usage: 
# upgrade-go 1.22.0
upgrade-go() {
   if [ $# -ne 1 ]; then
      echo "Usage: $ upgrade-go 1.22.0"
      return 1
   fi
   NEW_GO_VERSION=$1
   go install golang.org/dl/go$NEW_GO_VERSION@latest
   go$NEW_GO_VERSION download
   sudo mv "$(which go$NEW_GO_VERSION)" "$(which go)"
}

alias unistall-brew='/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/uninstall.sh)"'
alias install-brew='/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"'

# creates a lowercase uuid, saves into the clipboard and shows it in the terminal by pasting it
alias uuid="uuidgen | tr -d '\n' | tr '[:upper:]' '[:lower:]' | pbcopy; pbpaste"

alias docker-ip='sudo docker inspect --format="{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}"'
alias docker-ids='docker ps -q' # docker ps | cut -d " " -f 1
alias docker-ps='docker ps --format "{{.ID}} --- {{.Names}}"'
alias docker-images='docker images --format="{{.ID}} {{.Repository}}"'
alias docker-stop-all='docker stop $(docker ps -q) 2>/dev/null || echo "No containers running"'

# shows useful commands to clean up docker cache and free some space, according to the article: https://depot.dev/blog/docker-clear-cache
docker-clear() {
    echo "${GREEN}Possible actions: ${YELLOW}"
    echo "  docker container prune -f"
    echo "  docker image prune -f"
    echo "  docker image prune -a"
    echo "  docker volume prune -f"
    echo "  docker buildx prune -f"
    echo "  docker network prune -f"
    echo "  docker system prune -f"
    echo "  docker system prune --volumes -a -f"
    echo "${GREEN}"
    echo "Actual situation: ${YELLOW}"
    echo "  docker system df"
    echo "${RESET}"
    docker system df
}

# finds the networkID of a given container
# usage:
# $ docker-network <container-name>
docker-network() {
   docker inspect -f '{{range .NetworkSettings.Networks}}{{.NetworkID}}{{end}}' ${1}
   # docker run --network <network_id> <image_name>
}

# useful only for Mac OS Silicon M1, 
# still working but useless for the other platforms
docker() {
  if [[ `uname -m` == "arm64" ]] && [[ "$1" == "run" || "$1" == "build" || "$1" == "pull" ]]; then
    /usr/local/bin/docker run --platform linux/amd64 "${@:2}"
  else
     /usr/local/bin/docker "$@"
  fi
}

# allows using nerdctl (through colima started with --runtime containerd instead of docker)
# in a fully compatible way with docker.
# for example you can use -d and -i and -t tags like docker (with nerdctl is not possible):
# $ docker run -it -d -p 8080:8080 --name mynginx nginx:latest 
# $ nerdctl run -it -d -p 8080:8080 --name mynginx nginx:latest 
nerdctl() {
  if [ "$1" == "run" ]; then
      detached=false
      tty_or_interactive=false
      for arg in "${@:2}"; do
          if [ "$arg" == "-d" ]; then
            detached=true
          elif [ "$arg" == "-i" ] || [ "$arg" == "-t" ] || [ "$arg" == "-it" ]; then
            tty_or_interactive=true
          fi
      done
      if [ "$detached" == true ] && [ "$tty_or_interactive" == true ]; then
        args=()
        for arg in "${@:2}"; do
            if [ "$arg" != "-i" ] && [ "$arg" != "-t" ] && [ "$arg" != "-it" ]; then
              args+=("$arg")
            else
              echo "Warning: -d flag cannot be used in conjunction with $arg. Removing flag $arg."   
            fi
        done
        colima nerdctl -- run "${args[@]}"
      else
        colima nerdctl -- "$@"
      fi
  else
      colima nerdctl -- "$@"
  fi
}

# keeps track of the branch from which a new branch is created.
# it updates the history of the branch in case of rebase onto
# when the branch is deleted it deletes its history also
# es. (branchA) $ git checkout -b branchB
#     (branchB) $ git branch --onto branchC branchA 
#     (branchB) $ git branch history
#     branchB created from branchA
#     branchB rebased onto branchC
# What misses? the git switch command and the cancel operation for a rebase --onto
git() {

   if [ "${1}" == "checkout" ] && [ "${2}" == "-b" ]; then
      mkdir -p .git/branches_history
      if [ "${4}" != "" ]; then
        # git checkout -b <new-branch> <from-branch>
        echo "${3} created from ${4}" > .git/branches_history/${3}
      else
        # git checkout -b <new-branch>
        echo "${3} created from $(/usr/local/bin/git branch --show-current)" > .git/branches_history/${3}
      fi
    
   elif [ "${1}" == "rebase" ] && [ "${2}" == "--onto" ]; then
      mkdir -p .git/branches_history
      if [ "${5}" != "" ]; then
         # git rebase --onto <new-base> <old-base> <branch-to-be-rebased>
         echo "${5} rebased onto ${3}" >> .git/branches_history/${5}
      else 
         # git rebase --onto <new-base> <old-base>
         echo "$(/usr/local/bin/git branch --show-current) rebased onto ${3}" >> .git/branches_history/$(/usr/local/bin/git branch --show-current)
      fi
      
   elif [ "${1}" == "branch" ]; then
       if [ "${2}" == "-d" ] || [ "${2}" == "-D" ] || [ "${2}" == "--delete" ] || [ "${2}" == "--force-delete" ]; then
          # git branch -d <branch> | git branch -D <branch>
          rm -rf .git/branches_history/${3} &> /dev/null
       elif [ "${2}" == "history" ]; then
             if [ "${3}" != "" ]; then 
                # git branch history <branch>
                branchName=${3}
             else
                # git branch history
                branchName=$(/usr/local/bin/git branch --show-current)
             fi
             cat .git/branches_history/${branchName}
             # return because git branch history is not a real git command, so git doesn't have to do anything
             return 0
       fi
   fi
   # perform the real git command
   /usr/local/bin/git "${@}"
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
  name=go-in-docker-$RANDOM
  echo "executed in docker. Container name: $name"
  docker run --rm -d --network host -v $PWD:/usr/src/myapp -w /usr/src/myapp --name ${name} golang:1.17 go "$@"
  docker logs --follow ${name}
}

# SOME NOTES ON DELVE IN DOCKER
# build executable from docker
# $ docker exec -it delve go build -gcflags='-N -l'
# $ docker exec -it dlv bash -c "go mod download; GOOS=linux CGO_ENABLED=0 go install -gcflags='-N -l'; go build -gcflags='-N -l' -o delve-app"
# ... then you can do this
# $ docker exec -it delve dlv exec --listen=:2345 --api-version=2 ./delve-app
# ... or this 
# $ docker exec -it delve dlv debug
# $ docker exec -it dlv bash -c "go mod download; GOOS=linux CGO_ENABLED=0 go build -gcflags='-N -l' -o delve-app"
# $ docker exec -it delve dlv exec --listen=:2345 --headless=true --api-version=2 ./my-project-executable
# API server listening at: [::]:2345
# 2022-07-13T08:09:47Z warning layer=rpc Listening for remote connections (connections are not authenticated nor encrypted)
# ... version
# $ docker exec -it dlv bash -c 'dlv version’
# $ docker exec -it dlv bash -c 'dlv debug main.go’


# start debugging your golang project using delve in docker
# go in the folder of your project, for example:
#   $ cd myproject
# start delve in docker (a container named 'myproject-dlv' will be created):
#   $ delve start
# the container is starting in background. Once it's ready you can:
# - debug the project with:
#   $ delve debug
# - debug a test with:
#   $ delve test <path/to/file.go> <path/to/file_test.go>
# When it enters in debug mode you can execute the following steps:
# - set a breakpoint
#   (dlv) break handler/postalcode/get/get_postalcode_handler_test.go:183
# - continue to the next breakpoint
#   (dlv) continue
# - print variables on breakpoint
#   (dlv) print myVar.myAttr
# - show variable type
#   (dlv) whatis myVar.myAttr
# - show all the current variables
#   (dlv) vars
# - show a specific variable
#   (dlv) vars myVar.myAttr
# - display variable changes at each step
#   (dlv) display myVar.myAttr
# - force a value for a variable
#   (dlv) call myVar.myAttr = "hello"
# - evaluate an expression
#   (dlv) call myExpr(myInput)
# - continue to the next line
#   (dlv) next
# - enter in the next function call
#   (dlv) step
# - exit from the function call
#   (dlv) stepout
# - show arguments for the current function
#   (dlv) args
# - prints the current stack of calls
#   (dlv) stack
# - list of the threads for the process
#   (dlv) threads
# - list of the goroutines
#   (dlv) goroutines
delve() {
   container_name=${PWD##*/}-dlv
 
   if [ "$1" == "init" ] || [ "$1" == "start" ]; then
     
      if [ ! -z `docker ps | grep $container_name` ]; then
          echo "Delve is already running"
      elif [ ! -z `docker ps -a | grep $container_name` ]; then
          echo "Delve is already initialized. Starting..."
          docker start $container_name
      else
          echo "Preparing delve for the project..."
          /usr/local/bin/docker run -it -d \
            --platform linux/arm64/v8 \
            -p 2345:2345 \
            -v $PWD:/go/app/ \
            -w /go/app \
            --name $container_name \
            golang \
            bash -c '
              export GOROOT=$(go env GOROOT);
              export GOPATH=$(go env GOPATH);
              export PATH=$GOPATH/bin:$PATH;
              export PATH=$PATH:$GOROOT/bin;
              go install github.com/go-delve/delve/cmd/dlv@latest;
              tail -f /dev/null' > /dev/null
          # sleep 5
          while [ -z `docker exec -it $container_name bash -c "dlv version" | grep 'Delve Debugger'` ]
          do 
            printf '.'; sleep 1; printf '.'; sleep 1; printf '.'; sleep 1
            echo ""
            tput cuu 1 && tput el
          done 
          echo "Delve is started"   
      fi

   elif [ "$1" == "debug" ]; then
      docker exec -it $container_name dlv debug
   elif [ "$1" == "test" ]; then
      if [ "$2" != "help" ] || [ "$2" != "--help" ] || [ "$#" != 3 ]; then
         echo "delve test <path/to/file.go> <path/to/file_test.go>"
      else
         docker exec -it $container_name dlv test $2 $3
      fi
   elif [ "$1" == "stop" ]; then
      echo "stopping Delve..."
      docker stop $container_name > /dev/null
      sleep 1;
      echo "Delve stopped."
   elif [ "$1" == "remove" ]; then
      echo "removing Delve from your project..."
      docker rm -f $container_name > /dev/null
      sleep 1;
      echo "Delve removed."
   else
       docker exec -it $container_name dlv help
   fi   
}

# run bash5 by sharing the current directory as volume (MacOs doesn't have it!)
bash5() {
  docker run --rm -d -v ~:/root -w /root --name bash5 bash:5.1-alpine3.14 tail -f /dev/null; docker exec -it bash5 bash
}

# nohup implementation using disown: just to play!
# nohupp ./ciao 
# equivalent to
# nohup ./ciao &
# there is a problem! If you kill the PID it appears, the file is still filled by the background process
# so you must look for the process attached to it with: fuser -c nohup.out
nohupp() {
  ${@} &>nohup.out &
  disown
}

# finds processes attached to a file
alias who-is-using='fuser -c' # who-is-using output.txt

# explains how to have a background process
background-process() {
  echo "There are two ways:"
  echo ""
  echo "nohup ./ciao.sh &"
  echo "tail -f nohup.out"
  echo ""
  echo "./ciao.sh &>disown.out &"
  echo "disown"
  echo "tail -f disown.out"
}

# explains how to use jq
how-to-jq() {
   echo '{"Id": "abc123"}' | jq -r '.Id'
   echo '[{"Id": "abc123"}, {"Id": "def456"}]' | jq -r '.[] | .Id'
}

# instructions to build scripts
alias last-param='echo ${@: -1}'
alias all-but-last-param='echo ${@:1:$#-1}'

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

alias swagger='docker run -d -p 80:8080 --name swagger swaggerapi/swagger-editor'

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
# curl with time calculation
alias curlt='curl -s -w "%{time_total}\n" '

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
alias findfile='find . -type f -name' #<regex on name> es. '*.go'
alias finddir='find . -type d -name' #<regex on name> es. 'backup_*'

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
alias rm='rm -rf'

# usage: 
# $ t 1 # first level of the tree
# $ t 2 # first two level of the tree
# es. 
#[149M]  .
#├── [147M]  api-go
#│   ├── [1.0K]  Dockerfile
#│   ├── [ 11K]  README.md
alias t='tree --du -h -L'

# removes a file by overwriting its content so it's not recoverable anymore
# usage:
# $ secure-rm passwords.txt
# $ cat passwords.txt | secure-rm
secure-rm() {
  filename=$1
  if [ "$#" == 0 ]; then 
     filename=$( < /dev/stdin )
  fi
  shred -zvu -n 5 $1
  # -z add a final overwrite with zeros to hide shredding
  # -v shows progress
  # -u truncate and remove file after overwriting
  # -n overwrite n times instead of 1
}

# echo 345 | copy | paste
alias copy='xclip'
alias paste='xclip -o'

# inline functions (put spaces close to {}, put ; at the end of each command)
now() { date +"%A, %b %d, %Y %I:%M %p"; }

# Markdown file viewer
# Usage:
# $ md filename.md
md() {
   if [ -z "$1" ]; then
      echo "Please provide the name of the markdown (*.md) file you want to view"
      return
   fi
   if [ -z `which pandoc` ]; then
      printf "${RED}${BOLD}pandoc${RESET}${RED} is not installed! Please install${RESET}\n\n"
      return
   fi
   if [ -z `which lynx` ]; then
      printf "${RED}${BOLD}lynx${RESET}${RED} is not installed! Please install${RESET}\n\n"
      return
   fi
   pandoc ${1} | lynx -stdin
}

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

tablechars() {
   echo "┘ ┐ ┌ └ ┼ ├ ┤ ┴ ┬ │ ─"
   echo ""
   echo "┌────────┬────────┐"
   echo "├────┬───┴────┬───┤"
   echo "│    │        │   │"
   echo "├────┼────────┼───┤"
   echo "└────┴────────┴───┘"
}

# usage: random-string 10
alias random-string='tr -dc A-Za-z0-9 </dev/urandom | head -c'

alias c='clear'
alias d='docker'
alias g='git'
alias k='kubectl'

alias gut='echo "`tput setaf 5``tput bold`You probabily meant git`tput sgr0`"; git'
alias gi='echo "`tput setaf 5``tput bold`You probabily meant git`tput sgr0`"; git'

// performs a backup of all the resource in all namespaces and saves the manifests in the specified file
k8s-backup() {
   read -p "${YELLOW}insert the path of the backup file ${CYAN}[~/backup.yaml]${RESET}: " path
   path=${path:-$HOME/backup.yaml}
   kubectl get ns | cut -d ' ' -f 1 | xargs -I {} kubectl get all -n {} -o yaml >> ${path}
}

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
  filename=$1
  if [ "$#" == 0 ]; then 
     filename=$( < /dev/stdin )
  fi
    cat /dev/null > $filename
}

clear-file() {
  filename=$1
  if [ "$#" == 0 ]; then 
     filename=$( < /dev/stdin )
  fi
    > $filename
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

# helps finding the kubernetes resource through its uid:
# usage: 
# $ find-by-uid replicaset 290df10d-a42c-4c77-9db8-be1941de13c4
# you can type '/' and paste the uid to serach it into the snippet through less
function find-by-uid {
   #$ kubectl get civonetworks -A -o jsonpath='{range .items[*]}{.metadata.uid}{" -> "}{.metadata.name}{"\n"}'
    if [ "$#" != 2 ]; then 
       echo "you must specify the kind of the resource as first param and the uid as second param"
       return 0
    fi
    resourcename=$1
    uid=$2
    line=`kubectl get ${resourcename} -A -o yaml | grep ${uid} -n | cut -d ':' -f 1`
    if [ -z $line ]; then
       echo "uid not found for the specified resource"
       return 0
    fi
    headline=$(($line+100))
    newline=`kubectl get ${resourcename} -A -o yaml | head -${headline} | tail -200 | grep ${uid} -n | cut -d ':' -f 1`
    echo "uid found: give a look to line $newline of the given snippet"
    sleep 3
    kubectl get ${resourcename} -A -o yaml | head -${headline} | tail -200 | less -N
}

# helps find the k8s resource by its id
# usage:
# $ kget replicasets | grep ceeae26e-3292-4b0d-8c08-7bc934c56388
kget() {
   if [ "$#" != 1 ]; then
      echo "please specify the type of resource"
      return 0
   fi
   kubectl get ${1} -A -o jsonpath='{range .items[*]}{"id: "}{.metadata.uid}{" name: "}{.metadata.name}{" namespace: "}{.spec.namespace}{"\n"}'
}

kube-logs-cheatsheet() {
  echo "Cheatsheet:"
  echo "kubectl logs --since=15m <podname>"
  echo "kubectl logs --tail=100 -f <podname>"
  echo "kubectl logs --previous <podname>"
}

alias kube-get-context='kubectl config get-contexts'
alias kube-set-context='kubectl config use-context' #<context-name> check in the ~/.kube/config file or in the $KUBECONFIG env var
alias kube-logs='kubectl logs --tail=100 -f' # <podname> --namespace <namespacename>

alias tilde='echo "option+5 = ~ "'
alias apice='echo "backtick = option+9"'

# starts a pod with bash in the cluster current pointed by kubectl
alias gimme-a-shell='kubectl run -it shell --image=bash --restart=Never --rm -- bash'
# starts a pod with curl in the cluster current pointed by kubectl
alias gimme-a-curl='kubectl run -it curl --image=curlimages/curl --restart=Never --rm -- sh'

# starts redis-ui as docker container
# remember to reference other containers in the same host with the container ip and not with localhost
redis-ui() {
   docker start redis-ui || docker run -it -d -p 8001:8001 --name redis-ui redislabs/redisinsight:latest
   echo "Visit localhost:8001 on your browser!"
}

# ephemeral redis-cli terminal connected to a given host
# usage: redis-cli redis://docker.for.mac.localhost:6379
redis-cli() {
  if [ "$#" != 1 ]; then
    echo "you must specify 'redis://username:password@host:port/dbnumber' as argument"
    return 1
  fi
  # redis-cli -u redis://username:password@host:port
  docker run -it --rm --name redis-cli ubuntu:latest bash -c "apt-get update && apt-get install redis-tools -y; redis-cli -u ${1}; /bin/bash"
}

# for mac
#alias code='/Applications/Visual\ Studio\ Code.app/Contents/Resources/app/bin/code'

remove-first-last() {
  string=$1
  if [ "$#" == 0 ]; then 
     string=$( < /dev/stdin )
  fi
  echo "${string:1:${#string}-2}"
}

# translate word or sentence in italian
# usage:
# $ trans-it 'Hello to everybody!'
# $ trans-it look
alias trans-it='docker run -it --platform linux/amd64 --rm soimort/translate-shell en:it'

# translate word or sentence in english
# usage:
# $ trans-en 'Ciao a tutti!'
# $ trans-en osservare
alias trans-en='docker run -it --platform linux/amd64 --rm soimort/translate-shell it:en'

alias goenv='go env'
alias goenvs='go env'

clear

#CONTENT OF THE FILE ~/.gitconfig
#[alias]
#	ls = "!f() { git log $1 --pretty=format:\"%C(yellow)%h%Cred%d\\\\ %Creset%s%Cgreen\\\\ [%ae,%ar]\" --decorate --graph; }; f"
#	bl = blame -c --date=short
#	switch = "!f() { git checkout $1 2>/dev/null || git checkout -b $1; }; f"
#	wip = "!f() { git stash save $1 -u ; }; f"
#	wip-apply = "!f() { temp=$(git stash list | cut -d : -f 3 | grep -n -w $1 | cut -d : -f 1) ; stashnum=$((temp-1)) ; stashname=$(echo stash@{$stashnum}) ; git stash apply $stashname ; }; f"
#	commits-behind = "!f() { git fetch -tp > /dev/null 2>&1; git log --oneline $(git branch --show-current)..$1; }; f"
#	commits-diff = "!f() { git fetch -tp > /dev/null 2>&1; git log --oneline $(git branch --show-current)...$1; }; f"
#	branch-name = branch --show-current
#	tag-info = log -1 --format=%ai
#	behind = "!f() { git fetch -tp &>/dev/null; export BRANCH_NAME=$(git branch --show-current); git log --oneline $BRANCH_NAME..origin/${BRANCH_NAME}; }; f"
#	reset-hard = "!f() { git reset --hard; git clean -df ; }; f"
#	aliases = "!f() { git config --get-regexp \"^alias\\.\" | cut -d \" \" -f 1 | cut -d \".\" -f 2 ; }; f"
#	get-alias = "!f() { git config --get-regexp \"^alias\\.\" | grep $1 ; }; f"
#	whoami = "!f() { echo \"`git config user.name` `git config user.email`\"; }; f"
#	get-url = config --get remote.origin.url
#	set-url = "!f() { git remote set-url origin $1 ; }; f"
#	add-all = "!f() { git add . ; git restore --staged \"*/factory.lic\" ; }; f"
#	tags = "!f() { if [ \"$1\" == \"-r\" ] || [ \"$1\" == \"--remote\" ]; then git ls-remote --tags origin; else git tag; fi; }; f"
#	lasttag = "!f() { git fetch -tp &>/dev/null; git tag -l v${1}* --sort=v:refname | tail -1; }; f"
#	release = "!f() {                      \n    RESET=`tput sgr0`\n    GREEN=`tput setaf 2`\n    CYAN=`tput setaf 6`\n    YELLOW=`tput setaf 3`\n    BOLD=`tput bold` \n\n    LASTTAG=$(git lasttag)\n    [ \"$LASTTAG\" != \"\" ] || LASTTAG=\"v0.0.0\"\n    VERSION=$(echo \"$LASTTAG\" | cut -d v -f 2)\n                    \n    SPLITTED=(${VERSION//./ })                                 \n    for i in {0..2}                                            \n    do                                                         \n       SPLITTED[$i]=`echo ${SPLITTED[$i]} | cut -d - -f 1`   \n       [ \"${SPLITTED[$i]}\" != \"\" ] || SPLITTED[$i]=0           \n    done                                                       \n                                                               \n    INDEX=2  \n    if [ \"$1\" == \"--help\" ] || [ \"$1\" == \"-h\" ] || [ \"$1\" == \"--usage\" ]; then \n       echo \"\" \n       echo \"Creates a ${BOLD}${YELLOW}new tag${RESET} from the current commit.\"\n       echo \"Usage: \"\n       echo \"  git release ${GREEN}[--patch] ${CYAN}# creates a new patch release ${RESET}\"\n       echo \"  git release  --minor  ${CYAN}# creates a new minor release  ${RESET}\"\n       echo \"  git release  --major  ${CYAN}# creates a new major release  ${RESET}\"\n       exit 0\n    elif [[ \"$1\" == \"--major\" ]]; then                           \n       SPLITTED[0]=$((SPLITTED[0]+1))   \n       SPLITTED[1]=0\n       SPLITTED[2]=0                       \n       INDEX=0                                                 \n    elif [[ \"$1\" == \"--minor\" ]]; then                         \n       SPLITTED[1]=$((SPLITTED[1]+1))   \n       SPLITTED[2]=0                       \n       INDEX=1                                                 \n    else                                                       \n       SPLITTED[2]=$((SPLITTED[2]+1))                          \n    fi                                                         \n                                                       \n    echo \"Latest tag found: ${BOLD}${YELLOW} `git lasttag`${RESET}\"                                                           \n    git tag v${SPLITTED[0]}.${SPLITTED[1]}.${SPLITTED[2]}      \n    echo \"New release tag: ${BOLD}${GREEN} `git lasttag`${RESET}\"\n}; f"
#	ch = checkout
#	st = status
#	statsu = status
#	stats = status
#	tstatus = status
#	m = merge
#	com = commit
#	a = add
#	t = tag
#	f = fetch -tp
#	statys = status
#	statyus = status
#	x = log --oneline
#	statsy = status
#	addmod = "!f() { git ls-files --modified | xargs git add; }; f"
#	unstage = restore --staged .
#	revert-merge = revert -m 1.
#	stayus = status
#	sttaus = status
#	sttats = status
#	tag-date = "!f() { git log --tags --simplify-by-decoration --pretty=\"format:%ci %d\" | grep $1; }; f"
#	statuys = status
#	remote2remote = "!f() { git fetch -tp &>/dev/null; git checkout origin/$1 &> /dev/null; git push -f origin HEAD:refs/heads/$2; git checkout - > /dev/null; }; f"
#	get-remote-url = "!f() { git config --get remote.$1.url; }; f"
#	set-remote-url = "!f() { git remote set-url $1 $2 ; }; f"
#	reset-author = "!f() { git config user.email alexmawashi87@gmail.com; git config user.name \"alessandroargentieri\"; git commit --amend --reset-author; }; f"
#[http]
#	sslVerify = false
#[includeIf "gitdir:~/toplevelFolder1/"]
#    path = ~/Desktop/work/projects/.gitconfig_include
#[pull]
#	rebase = false

#CONTENT OF THE FILE ~/Desktop/work/projects/.gitconfig_include
#[user]
#    name = Alessandro Argentieri
#    email = alessandro.argentieri@overit.it
