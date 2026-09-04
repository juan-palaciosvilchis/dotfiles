# ~/dotfiles/bash/.functions.sh

# make a directory and step once into it
#	usage: ...
mkcd() { mkdir -p "$1" && cd "$1"; }

# generic archive extractor
#	usage: ...
extract() {
  if [ -z "$1" ] || [ ! -f "$1" ]; then
    echo "Usage: extract <archive>"
    return 1
  fi
  case "$1" in
    *.tar.bz2) tar xjf "$1" ;;
    *.tar.gz)  tar xzf "$1" ;;
    *.tar.xz)  tar xJf "$1" ;;
    *.zip)     unzip "$1"   ;;
    *.gz)      gunzip "$1"  ;;
    *.tar)     tar xf "$1"  ;;
    *)         echo "extract: unknown archive format '$1'" ;;
  esac
}

# quick timestamped backup
# 	usage: backup foo.txt -> foo.txt.back.<timestamp>

# reload shell
#	usage: ...
