# ~/.bashrc

case "$TERM" in
    st-*)
	export TERM="$(sed 's/^st-/xterm-/' <<< "$TERM")"
	;;
esac


# terminal specific features
RED="$(tput setaf 1)"
GREEN="$(tput setaf 2)"
RESET="$(tput sgr0)"

# shell features
shopt -s cdspell checkwinsize dirspell dotglob globstar nullglob
HISTCONTROL=ignoredups

# modify prompt
PS1='\[$RED\]${?/#0/\[$GREEN\]}[\u@\h \W]\$ \[$RESET\]'

# useful variables
unitfile_regex='\.(service|socket|timer)$'

mirrorlist() {
    local url="https://www.archlinux.org/mirrorlist/?country=${1:-CA}" 
    curl -sL "$url" | sed s/^#// | rankmirrors - | tee mirrorlist
}

package() {
    case "$1" in
	-i)
	    shift
	    local groups="$(command pacman -Qge | cut -d ' ' -f 1 | sort -u)"
	    for group; do
		groups="$(fgrep -xv "$group" <<< "$groups")" 
	    done
	    echo "$groups"
	    echo
	    comm -3 <(pacman -Qqe | sort -u) <(pacman -Qqge $groups | sort -u)
	    ;;
	-R)
	    shift
	    sudo pacman -D --asdeps "$@"
	    while sudo pacman -R --noconfirm $(pacman -Qqdt); do
		:
	    done
	    ;;
	*)
	    if s command -v pacaur; then
		pacaur "$@"
	    else
		sudo pacman "$@"
	    fi
	    ;;
    esac
}

pb() {
    curl -F "c=@${1:--}" "https://ptpb.pw/?u=1"
}

s() {
    "$@" > /dev/null 2>&1
}

function sudo() {
    if [ "$UID" = 0 ]; then
	"$@"
    else
	command sudo "$@"
    fi
}

# aliases
alias cmake='cmake -DCMAKE_EXPORT_COMPILE_COMMANDS=ON'
alias config='git -C ~/config'
alias df='df -h'
alias diff='diff -aur'
alias docker='sudo docker'
alias docker-compose='sudo docker-compose'
alias du='du -h'
alias e='$EDITOR'
alias emacs='emacs --no-splash'
alias gpgv='gpg --verify'
alias grep='grep --color=auto'
alias igrep='grep -i'
alias lns='ln -sfr'
alias ls='ls --color=auto -FC'
alias pacaur='pacaur --rsort votes'
alias qrencode='qrencode -t ANSI'
alias tcpdump='sudo tcpdump -Z $USER'
alias xclip='xclip -selection clipboard'

# completions
s . /usr/share/bash-completion/completions/git
eval "$(complete -p git | sed 's/git$/config/')"
s . /usr/share/cmake-*/completions/*
