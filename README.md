# curly-bash
The config files I use for my shell. Hope it's helpful !

## bashrc
In your bashrc, you could add:

	source /path/to/curly-bash.sh

## screenrc
I didn't find an easy way to source it...

Just add a symbolic link on it.

## gitconfig
Add a section in your ~/.gitconfig:

	[include]
		path = /path/to/curly-gitconfig.inc

## vimrc
Add a line in your ~/.vimrc:

	source /path/to/curly-vimrc
