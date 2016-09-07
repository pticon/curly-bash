#!/bin/bash
#
# You should set (before sourcing this):
#	MYPROXY to your proxy environment
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

alias top='htop'

# Wraps Sprunge, a commandline pastebin tool
# echo "hello" | sprunge
# cat file | sprunge
alias sprunge='curl -F "sprunge=<-" http://sprunge.us'

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

function check_tor()
{
	echo "Checking that Tor is currently running ... "
	local check5=$(pgrep tor | wc -l)
	if [[ "$check5" == "0" ]] ; then
		echo "Process for Tor not found ..."
		echo "Tor is not currently running ..."
		echo "Starting Tor ..."
		if test -x /etc/init.d/tor ; then
			sudo /etc/init.d/tor start
		else
			echo "Could not find init script for Tor ..."
			echo "Exiting ..."
			exit 1
		fi
	else
		echo "Tor process found ..."
		echo "Tor is currently running ..."
	fi
}

# Run $@ if it isn't running already.
function only()
{
	if [ -z "`ps -Af | grep -o -w ".*$1" | grep -v grep | grep -v only`" ] ; then
	    $@
	fi
}

function quiet()
{
	nohup $1 &>/dev/null &
}

function top10()
{
	history | awk '{CMD[$2]++;count++;}END { for (a in CMD)print CMD[a] " " CMD[a]/count*100 "% " a;}' \
		| grep -v "./" | column -c3 -s " " -t | sort -nr | nl |  head -n10
}

function rot13 ()
{
        if [ $# -eq 0 ]; then
                tr '[a-m][n-z][A-M][N-Z]' '[n-z][a-m][N-Z][A-M]'
        else
                echo $* | tr '[a-m][n-z][A-M][N-Z]' '[n-z][a-m][N-Z][A-M]'
        fi
}

# A bash clock that can run in your terminal window.
function clock()
{
	while true;
	do
		clear;
		echo "===========";
		date +"%r";
		echo "===========";
		sleep 1;
	done
}

# Stupid simple note taker
function note ()
{
        #if file doesn't exist, create it
        [ -f $HOME/.notes ] || touch $HOME/.notes

        #no arguments, print file
        if [ $# = 0 ]
        then
                cat $HOME/.notes
        #clear file
        elif [ $1 = -c ]
        then
                > $HOME/.notes
        #add all arguments to file
        else
                echo "$@" >> $HOME/.notes
        fi
}

# cp with a progress bar
function cp_p()
{
   set -e
   strace -q -ewrite cp -- "${1}" "${2}" 2>&1 \
      | awk '{
        count += $NF
            if (count % 10 == 0) {
               percent = count / total_size * 100
               printf "%3d%% [", percent
               for (i=0;i<=percent;i++)
                  printf "="
               printf ">"
               for (i=percent;i<100;i++)
                  printf " "
               printf "]\r"
            }
         }
         END { print "" }' total_size=$(stat -c '%s' "${1}") count=0
}


# Color man pages
#export LESS_TERMCAP_mb=$(printf '\e[01;31m') # enter blinking mode - red
#export LESS_TERMCAP_md=$(printf '\e[01;35m') # enter double-bright mode - bold, magenta
#export LESS_TERMCAP_me=$(printf '\e[0m') # turn off all appearance modes (mb, md, so, us)
#export LESS_TERMCAP_se=$(printf '\e[0m') # leave standout mode
#export LESS_TERMCAP_so=$(printf '\e[01;33m') # enter standout mode - yellow
#export LESS_TERMCAP_ue=$(printf '\e[0m') # leave underline mode
#export LESS_TERMCAP_us=$(printf '\e[04;36m') # enter underline mode - cyan

export LESS_TERMCAP_mb=$(printf '\e[01;31m') # enter blinking mode
export LESS_TERMCAP_md=$(printf '\e[01;38;5;75m') # enter double-bright mode
export LESS_TERMCAP_me=$(printf '\e[0m') # turn off all appearance modes (mb, md, so, us)
export LESS_TERMCAP_se=$(printf '\e[0m') # leave standout mode
export LESS_TERMCAP_so=$(printf '\e[01;33m') # enter standout mode
export LESS_TERMCAP_ue=$(printf '\e[0m') # leave underline mode
export LESS_TERMCAP_us=$(printf '\e[04;38;5;200m') # enter underline mode


# PS1
if [ $(/usr/bin/whoami) = 'root' ]; then
    export PS1="${yellow}\u@\h${white}:${norm}\w${norm}${lred}#${norm} "
else
    export PS1="${yellow}\u@\h${white}:${norm}\w${norm}\$ "
fi
