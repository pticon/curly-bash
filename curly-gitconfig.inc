[user]
	name = Pierre Lebleu
	email = pierre.lebleu@technicolor.com

[color]
	ui = auto

[color "branch"]
	current = yellow reverse
	local = yellow
	remote = green

[color "diff"]
	meta = yellow bold
	frag = magenta bold
	old = red bold
	new = green bold

[color "status"]
	added = yellow
	changed = green
	untracked = cyan

[alias]
	co = checkout
	st = status
	br = branch
	hist = log --pretty=format:\"%h %ad | %s%d [%an]\" --graph --date=short
	type = cat-file -t
	dump = cat-file -p

[diff]
        tool = vindiff

[difftool]
        prompt = false

[merge]
        tool = vimdiff

[mergetool]
        prompt = false

[core]
	editor = vim
