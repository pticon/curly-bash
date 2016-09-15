#!/bin/bash
#
# Check this out for more:
# http://intuitive.com/wicked/wicked-cool-shell-script-library.shtml
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
alias llh='ls -lh'
alias lla='ls -la'
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

alias scope='cscope -bR'

alias more='less'

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

# Take care of the OUI and avoid some issue with the b0 and b1 which are the "multicast" bit and
# the "local" bit respectively
function random_ether()
{
	echo "64:00:6a$(openssl rand 3 | hexdump -e '/1 ":%02x"')"
}

function set_random_ether()
{
	local iface="$1"

	[ -n "$iface" ] || return

	sudo ip link set dev $iface down
	sudo ip link set dev $iface addr $(random_ether)
	sudo ip link set dev $iface up
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
			*.tbz2|*.tar.bz2)
				tar xjf $archive ;;

			*.tgz|*.tar.gz)
				tar xzf $archive ;;

			*.bz2)
				bunzip2 $archive ;;

			*.rar)
				rar x $archive ;;

			*.gz)
				gunzip $archive ;;

			*.tar)
				tar xf $archive ;;

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
			return 1
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

function noscreensaver()
{
	xset -dpms; xset s noblank; xset s off
}

function rebash()
{
	. ~/.bashrc
}

function findsuid()
{
	local mtime="7"	# how far back (in days) to check for modified cmds
	local verbose=0	# by default, let's be quiet about things

	if [ "$1" = "-v" ] ; then
	  verbose=1
	fi

	for match in $(find /bin /usr/bin -type f -perm +4000 -print)
	do
	  if [ -x $match ] ; then

	    local owner="$(ls -ld $match | awk '{print $3}')"
	    local perms="$(ls -ld $match | cut -c5-10 | grep 'w')"

	    if [ ! -z $perms ] ; then
	      echo "**** $match (writeable and setuid $owner)"
	    elif [ ! -z $(find $match -mtime -$mtime -print) ] ; then
	      echo "**** $match (modified within $mtime days and setuid $owner)"
	    elif [ $verbose -eq 1 ] ; then
	      local lastmod="$(ls -ld $match | awk '{print $6, $7, $8}')"
	      echo "     $match (setuid $owner, last modified $lastmod)"
	    fi
	  fi
	done
}

# backup file
function bu()
{
	local original="$1"

	[ -n "$original" ] || return

	cp -r "$original" "${original}-$(date '+%D-%R' | tr '/' '-' | tr ':' '_')"
}

# very useful for debugging bash script
# +(somefile.bash:412): myfunc(): echo 'Hello world'
function debugbash()
{
	export PS4='+(${BASH_SOURCE}:${LINENO}): ${FUNCNAME[0]:+${FUNCNAME[0]}(): }'
}

function undebugbash()
{
	export PS4=''
}

# Dos to unix
# remove '\r'
function dtox()
{
	local dos="$1"

	[ -n "$dos" ] || return

	cat $dos | tr -d '\r'
}

function diskspace() {
	local tempfile=`mktemp`

	cat << 'EOF' > $tempfile
		{ sum += $4 }
	END {
		mb = sum / 1024
		gb = mb / 1024
		printf "%.0f MB (%.2fGB) of available disk space\n", mb, gb
	}
EOF

	df -k | awk -f $tempfile
	rm -f $tempfile
}

function clearpass()
{
	local iface="$1"

	[ -n "$iface" ] || (echo "Please specify interface" && return)

	sudo tcpdump -i $iface port http or port ftp or port smtp or port imap or port pop3 or port rpc -l -A \
		| egrep -i 'pass=|pwd=|log=|login=|user=|username=|pw=|passw=|passwd=|password=|name=|name:|pass:|user:|username:|password:|login:|pass |user |passwd.byname' --color=auto --line-buffered -B20
}

function lastlogin()
{
	lastlog | grep -v Never
}

# Useful to have the header of the command
function header()
{
	local cmd="$1"
	local grepper="$2"

	$cmd | head -1 && $cmd | grep $grepper
}


# color
export black="\[\033[0;38;5;0m\]"
export red="\[\033[0;38;5;1m\]"
export orange="\[\033[0;38;5;130m\]"
export green="\[\033[0;38;5;2m\]"
export yellow="\[\033[0;38;5;3m\]"
export blue="\[\033[0;38;5;4m\]"
export bblue="\[\033[0;38;5;12m\]"
export magenta="\[\033[0;38;5;55m\]"
export cyan="\[\033[0;38;5;6m\]"
export white="\[\033[0;38;5;7m\]"
export coldblue="\[\033[0;38;5;33m\]"
export smoothblue="\[\033[0;38;5;111m\]"
export iceblue="\[\033[0;38;5;45m\]"
export turqoise="\[\033[0;38;5;50m\]"
export smoothgreen="\[\033[0;38;5;42m\]"


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
