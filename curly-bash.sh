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

which most > /dev/null
if [ $? = 0 ]; then
export PAGER=most
else
export PAGER=less
fi


# alias stuffs
alias la='ls -a'
alias ll='ls -l'
alias llh='ls -lh'
alias lla='ls -la'
alias ls='ls --color'
alias l='ls'
alias sl='ls'
alias grpe='grep'
alias gpre='grep'

alias s='cd ..'
alias ..='cd ..'

alias grep='grep --color'
alias egrep='egrep --color'
alias fgrep='fgrep --color'
alias grpe='grep'
alias fgrpe='fgrep'
alias egrpe='egrep'

alias boxserial='cu -s 115200 -l /dev/ttyUSB0'

alias vi='vim'
alias edit='vim'

alias sha1='openssl sha1'

alias meminfo='free -m -l -t'

alias serve='python -m SimpleHTTPServer'

alias flush='sync'

alias psme='ps -ef | grep $USER'

alias nocomment='grep -Ev '\''^(#|$|;)'\'''

alias now='date +"%T"'

alias top='htop'

alias scope='cscope -bR'

alias more='less'

alias upgrade='sudo apt-get update && sudo apt-get upgrade -y'
alias distupgrade='sudo apt-get update && sudo apt-get dist-upgrade -y'

alias ff="find . -type f"

alias fuck='sudo $(history -p \!\!)'
alias please=fuck

# Wraps Sprunge, a commandline pastebin tool
# echo "hello" | sprunge
# cat file | sprunge
alias sprunge='curl -F "sprunge=<-" http://sprunge.us'

# Get the latest file in the current dir
alias latest='ls -t -1 -d * | head -n 1'

# function stuffs
function lllh()
{
    local link="$1"

    [ -z "${link}" -o ! -L "${link}" ] && {
        echo "lllh <symlink>"
        return
    }

    ls -lh `readlink -f ${link}`
}

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

	[ -z "$mydir" ] && {
		echo "cdmk: missing operand"
		return -1
	}

	mkdir -p "$mydir" && cd "$mydir"
}

function mkcd()
{
	cdmk $@
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

# Autocompletion for set_random_ether
function _set_random_ether()
{
	local cur="${COMP_WORDS[COMP_CWORD]}"

	COMPREPLY=( $(compgen -W "`ip link show | grep state | cut -d ':' -f 2`" -- ${cur}) )
	return 0
}
complete -F _set_random_ether set_random_ether

function up()
{
	local counter=$1
	local up=""

	[ -n "$counter" ] || counter=1

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

	if [ -f "$archive" ] ; then
		case "$archive" in
			*.tbz2|*.tar.bz2)
				tar xvjf "$archive" ;;

			*.tgz|*.tar.gz)
				tar xvzf "$archive" ;;

			*.bz2)
				bunzip2 "$archive" ;;

			*.rar)
				rar x "$archive" ;;

			*.gz)
				gunzip "$archive" ;;

			*.tar)
				tar vxf $archive ;;

			*.zip)
				unzip -v "$archive" ;;

			*.Z)
				uncompress "$archive" ;;

			*.tar.xz|*.txz)
				tar vxfJ "$archive" ;;

			*.xz)
				unxz "$archive" ;;

			*.7z)
				7z x $archive ;;

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
		echo "Tor IP : $(proxychains myip | grep -v ProxyChains)"
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

# FIXME
# allow arguments for the find command
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

# Bookmarks directories
function cdb()
{
	local bookmarks="$HOME/.cdbookmarks"

	if [ ! -e $bookmarks ]; then
		mkdir $bookmarks
	fi

	case $1 in
		-c) shift
		if [ ! -f $bookmarks/$1 ]; then
			echo "cd `pwd`" > $bookmarks/$1
		else
			echo "Bookmark $1 already exists !"
		fi
		;;

		-g) shift
		if [ -f $bookmarks/$1 ]; then
			source $bookmarks/$1
		else
			echo "No such bookmark: $1"
		fi
		;;

		-d) shift
		if [ -f $bookmarks/$1 ]; then
			rm -f $bookmarks/$1
		fi
		;;

		-l) shift
		local i
		for i in $(ls $bookmarks/); do
			echo -n "$i: "
			cat $bookmarks/$i | cut -d " " -f 2
		done
		;;


		*) echo "cdb [-c|-g|-d|-l] [bookmark]"
		;;
	esac
}

# Autocompletion for cdb()
_cdb()
{
	local bookmarks="$HOME/.cdbookmarks"
	local cur prev opts
	COMPREPLY=()

	cur="${COMP_WORDS[COMP_CWORD]}"
	prev="${COMP_WORDS[COMP_CWORD-1]}"
	opts="-c -g -d -l -h"

	if [[ ${cur} == -* ]]; then
		COMPREPLY=( $(compgen -W "${opts}" -- ${cur}) )
		return 0
	fi

	case ${prev} in
		-g|-d)
		COMPREPLY=( $(compgen -W "`ls $bookmarks`" -- ${cur}) )
		return 0
		;;
	esac
}
complete -F _cdb cdb

function addrif4()
{
	local iface=$1

	if [ ! -n "$iface" ]; then
		echo "No interface specified"
		return
	fi

	ip addr show "$1" | grep -w inet | awk '{print $2}' | cut -d '/' -f 1
}

function addrif6()
{
	local iface=$1

	if [ ! -n "$iface" ]; then
		echo "No interface specified"
		return
	fi

	ip addr show "$1" | awk '/inet6/ {print $2}' | cut -d '/' -f 1
}

function _addrif()
{
	local cur prev opts
	COMPREPLY=()

	cur="${COMP_WORDS[COMP_CWORD]}"
	prev="${COMP_WORDS[COMP_CWORD-1]}"

	if [ ! -n "$prev" ]; then
		return
	fi

	COMPREPLY=( $(compgen -W "`ip link show | grep state | cut -d ':' -f 2 | cut -d '@' -f 1`" -- ${cur}) )
}
complete -F _addrif addrif4
complete -F _addrif addrif6
complete -F _addrif ifconfig

function vlanadd()
{
	local interface="$1"
	local vlan="$2"

	if [ -z "$interface" ] || [ -z "$vlan" ] ; then
		echo "vlanadd <interface> <vlanid>"
	else
		sudo ip link add link $interface name $interface.$vlan type vlan id $vlan
		sudo ifconfig $interface.$vlan up
		ifconfig $interface.$vlan
	fi
}
complete -F _addrif vlanadd

# Forward all the received traffic to the specified interface
# see ip masquerade
function ipforward()
{
	local outif=$1

	if [ ! -n "$outif" ]; then
		echo "No interface specified"
		return
	fi

	sudo sysctl -w net.ipv4.ip_forward=1

	sudo iptables -t nat -F
	sudo iptables -t nat -A POSTROUNTIG -o $outif -j SNAT --to $(addrif $outif)
}

function rmmk()
{
	local target="$1"

	[ -n "$target" ] || return

	rm -fr $1 && mkdir $1
}

function sshremove()
{
	local ip="$1"

	[ -n "${ip}" ] || {
		echo "usage: sshremove <ip>"
		return
	}

	ssh-keygen -f "${HOME}/.ssh/known_hosts" -R ${ip}
}

function endianness()
{
	local R=`echo -n I | hexdump -o | awk '{ print substr($2,6,1); exit}'`

	if [ "$R" -eq 1 ]; then
		echo "little"
	else
		echo "big"
	fi
}

function screenshot() # imagename
{
	import -window root -display :0.0 -screen $@
}

function socksproxy()
{
	local server="$1"
	local user="${2:-root}"
	local proxyport="${3:-1080}"
	local sport="${4:-22}"

	[ -z "${server}" ] && {
		echo "socksproxy <srv> [usr] [socks port] [srv port]"
		return
	}

	ssh -D "${proxyport}" -f -C -q -N -p "${sport}" "${user}"@"${server}" && {
		echo "A socks proxy is open on localhost:${proxyport} -> ${server}:${sport}"
		echo "chromium --proxy-server=\"socks5://localhost:${proxyport}\""
	}
}

function sshnopasswd()
{
	local server="$1"
	local user="${2:-root}"
	local port="${3:-22}"
	local remoteauthkeys="$4"
	local localpubkey="$5"

	[ -z "$server" ] && {
		echo "sshnopasswd <srv> [usr] [port] [remoteauthkey] [localpubkey]"
		echo "example:"
		echo -e "\tsshnopasswd 192.168.1.1 root 22 /etc/dropbear/authorized_keys ~/.ssh/id_rsa.pub"
		return
	}

	[ -z "$remoteauthkeys" ] && remoteauthkeys="~/.ssh/authorized_keys"
	[ -z "$localpubkey" ] && localpubkey="~/.ssh/id_rsa.pub"

	cat $localpubkey | ssh -p "$port" "$user"@"$server" "cat - >> $remoteauthkeys"
}

function youtube2mp3()
{
	local url="$1"
	shift

	[ -z "$url" ] && {
		echo "youtube2mp3 <url>"
		return
	}

	local prg="$(which youtube-dl)"

	[ -z "$prg" ] && {
		echo "youtube-dl not installed !"
		echo "You should do :"
		echo "wget https://yt-dl.org/downloads/latest/youtube-dl"
		echo "chmod +x youtube-dl"
		echo "sudo mv youtube-dl /usr/local/bin/"
		return
	}

	youtube-dl --extract-audio --audio-format mp3 "$url" $*
}

function retry_until_success()
{
	while ! $@ ; do sleep 1 ; done
}

function skel_c()
{
	echo -e "#include <stdio.h>\n\nint main(int argc, char *argv[])\n{\n\treturn 0;\n}"
}

function skel_c_makefile()
{
	echo -e "TARGET=\n\n"
	echo -e "CC:=gcc\nLD:=gcc\nCFLAGS:=-Wall\nLDFLAGS:=\n\n"
	echo -e "ifeq (\$(DEBUG), 1)\nCFLAGS+=-O0 -g -DDEBUG\nelse\nCFLAGS+=-O3\nendif\n\n"
	echo -e "ifeq (\$(VERBOSE),1)\nQ=\necho-cmd=\nelse\nQ=@\necho-cmd=@echo \$(1)\nendif\n\n"
	echo -e "SRCS:=main.c\nSRCS+=\n\n"
	echo -e "OBJS:=\$(SRCS:%.c=%.o)\n\n"
	echo -e "all: \$(TARGET)\n\n"
	echo -e "\$(TARGET): \$(OBJS)\n\t\$(call echo-cmd, \"  LD   \$@\")\n\t\$(Q)\$(LD) -o \$@ \$^ \$(LDFLAGS)\n\n"
	echo -e "%.o: %.c\n\t\$(call echo-cmd, \"  CC   \$@\")\n\t\$(Q)\$(CC) \$(CFLAGS) -c \$< -o \$@\n\n"
	echo -e ".PHONY: clean\n\n"
	echo -e "clean:\n\t\$(call echo-cmd, \"  CLEAN\")\n\t\$(Q)rm -f \$(TARGET) \$(OBJS)"
}

function skel_c_mod()
{
	echo -e "#include <linux/init.h>\n#include <linux/module.h>\n#include <linux/kernel.h>\n"
	echo -e "static int __init lkm_init(void)\n{\n\treturn 0;\n}\n"
	echo -e "static void __exit lkm_exit(void)\n{\n}\n"
	echo -e "module_init(lkm_init);\nmodule_exit(lkm_exit);\n"
	echo -e "MODULE_LICENSE(\"GPL\");\n"
}

function skel_python()
{
	echo -e "#!/usr/bin/env python\n# *-* coding: utf-8 *-*\n\nif __name__ == "__main__":\n\tpass"
}

function skel_bash()
{
	cat <<EOF
#!/bin/bash

do_usage()
{
    echo "Usage: \$0" 1>&2
    exit 1
}

do_log()
{
    local fmt="\$@"
    echo "[\`date '+%d/%m/%Y %H:%M:%S'\`] \${fmt}"
}

do_parse_options()
{
    local o
    local s

    while getopts "s:h" o; do
        case "\${o}" in
            s)
                s=\${OPTARG}
                ((s == 45 || s == 90)) || usage
                ;;
            *)
                usage
                ;;
        esac
    done
    shift \$((OPTIND-1))

    if [ -z "\${s}" ] ; then
        usage
    fi
}

do_parse_options

EOF
}

function ip2geo () 
{
    local ip="$1"

    # Check if IP address is provided
    if [ -z "$ip" ]; then
        echo "Usage: ip2geo <ipaddr>"
        return 1
    fi

    # Check if required tools are available
    for cmd in curl jq; do
        if ! command -v $cmd &> /dev/null; then
            echo "Error: $cmd is not installed." >&2
            return 1
        fi
    done

    # Fetch and process geolocation data using ipinfo.io
    local response=$(curl -s "http://ipinfo.io/$ip/json")

    # Check if the response contains valid data
    if [[ "$response" == *"error"* ]]; then
        echo "Error: Invalid IP address or no data found." >&2
        return 1
    fi

    # Use jq to parse and format the JSON data
    echo "$response" | jq '.ip, .hostname, .city, .region, .country, .org'
}

function unixpath2dospath()
{
    local path="$1"

    [ -z "${path}" ] && {
        echo "unixpath2dospath <path>"
        return
    }

    echo "${path}" | tr '/' '\\'
}

function dospath2unixpath()
{
    local path="$1"

    [ -z "${path}" ] && {
        echo "dospath2unixpath <path>"
        return
    }

    echo "${path}" | tr '\\' '/'
}

# Per directory history
function history_guardian()
{
    local cmd="history_guardian"
    local arg="$1"

    [ -z "${arg}" ] && {
        echo "${cmd} <start|stop|status>"
        return
    }

    case "${arg}" in
        start)
        [ -n "${HISTORY_GUARDIAN}" ] && {
             echo "${cmd} is already activated on `dirname ${HISTFILE}`"
             return -1
        } || {
             history -a
             export HISTORY_GUARDIAN="${HISTFILE}"
             export HISTFILE="${PWD}/.history"
             touch ${HISTFILE}
        }
        ;;

        stop)
        [ -z "${HISTORY_GUARDIAN}" ] && {
             echo "${cmd} is already desactivated"
             return -1
        } || {
             history -a
             export HISTFILE="${HISTORY_GUARDIAN}"
             unset HISTORY_GUARDIAN
        }
        ;;

        status)
        [ -z "${HISTORY_GUARDIAN}" ] && \
             echo "${cmd} desactivated" || \
             echo "${cmd} activated"
        return
        ;;

        *)
        echo "${cmd} <start|stop|status>"
        return -1
        ;;
    esac

    # read the histoy file and append contents to the list
    history -r ${HISTFILE}
}

function patch_reverse()
{
    local cmd='patch_reverse'
    local p="$1"

    [ -z "$p" ] && {
        echo "${cmd} file.patch"
        return
    }

    which interdiff > /dev/null
    [ $? -ne 0 ] && {
        echo "No interdiff command available"
        echo "sudo apt install patchutils"
        return
    }

    interdiff -q $p /dev/null
}

function rand_pw()
{
    local cmd='rand_pw'
    local length="$1"

    [ -z "$length" ] && {
        echo "${cmd} <password_length>"
        return
    }

    < /dev/urandom tr -dc _A-Z-a-z-0-9 | head -c ${1:-$length} ; echo
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

# colored GCC warnings and errors
export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'


# PS1
if [ $(/usr/bin/whoami) = 'root' ]; then
    export PS1="${yellow}\u@\h ${orange}\T ${white}${norm}\w${norm}${lred}#${norm} "
else
    export PS1="${yellow}\u@\h ${orange}\T ${white}${norm}\w${norm}\$ "
fi
