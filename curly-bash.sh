#!/bin/bash
#
# You should set:
# MYPROXY to your proxy environment
#

#export MYPROXY=

# Use bash-completion, if available
if [ -f /etc/bash_completion ]; then
  . /etc/bash_completion
fi


# env stuffs
export EDITOR=vim
export PAGER=less


# alias stuffs
alias la='ls -a'
alias ll='ls -l'
alias llh='ll -lh'
alias ls='ls --color'
alias l='ls'
alias sl='ls'

alias s='cd ..'
alias ..='cd ..'

alias grep='grep --color'
alias egrep='egrep --color'
alias fgrep='fgrep --color'

alias boxserial='cu -s 115200 -l /dev/ttyUSB0'

alias vi='vim'
alias edit='vim'

alias sha1='openssl sha1'

alias meminfo='free -m -l -t'

alias serve='python -m SimpleHTTPServer'

alias flush='sync'

alias psme='ps -ef | grep $USER'

alias nocomment='grep -Ev '\''^(#|$)'\'''

alias now='date +"%T"'


# function stuffs
function setproxy()
{
	export ftp_proxy=$MYPROXY
	export http_proxy=$MYPROXY
	export https_proxy=$MYPROXY
	export FTP_PROXY=$MYPROXY
	export HTTP_PROXY=$MYPROXY
	export HTTPS_PROXY=$MYPROXY
}

function unsetproxy()
{
	export ftp_proxy=""
	export http_proxy=""
	export https_proxy=""
	export FTP_PROXY=""
	export HTTP_PROXY=""
	export HTTPS_PROXY=""
}

function myip()
{
	wget -qO - http://ipinfo.io/ip
}

function cdmk()
{
	local mydir="$1"
	mkdir -p "$mydir" && cd "$mydir"
}

function random_ether()
{
	echo "$(openssl rand 1 | hexdump -e '/1 "%02x"')""$(openssl rand 5 | hexdump -e '/1 ":%02x"')"
}

function up()
{
	local counter=$1
	local up=""

	[ -n "$counter" ] || return

	while [[ $counter -gt 0 ]]
	do
		up="../$up"
		counter=$(( $counter - 1 ))
	done

	echo "cd $up"
	cd $up
}

function cdl()
{
	local path="$@"

	cd $path && ls -al
}

function extract()
{
	local archive="$1"

	[ -n "$archive" ] || return

	if [ -f $archive ] ; then
		case $archive in
			*.tar.bz2)
				tar xjf $archive ;;

			*.tar.gz)
				tar xzf $archive ;;

			*.bz2)
				bunzip2 $archive ;;

			*.rar)
				rar x $archive ;;

			*.gz)
				gunzip $archive ;;

			*.tar)
				tar xf $archive ;;

			*.tbz2)
				tar xjf $archive ;;

			gz)
				tar xzf $archive ;;

			*.zip)
				unzip $archive ;;

			*.Z)
				uncompress $archive ;;

			*)
				echo "'$archive' cannot be extracted via extract()" ;;
		esac
	else
		echo "'$archive' is not a valid file"
	fi
}

function smiley()
{
	echo "●"
}


# PS1
if [ $(/usr/bin/whoami) = 'root' ]; then
    export PS1="${yellow}\u@\h${white}:${norm}\w${norm}${lred}#${norm} "
else
    export PS1="${yellow}\u@\h${white}:${norm}\w${norm}\$ "
fi
