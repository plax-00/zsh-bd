bd () {
  (($#<1)) && {
    print -- "usage: $0 <name-of-any-parent-directory>"
    print -- "       $0 <number-of-folders>"
    return 1
  } >&2
  # example:
  #   $PWD == /home/arash/abc ==> $num_folders_we_are_in == 3
  local num_folders_we_are_in=${#${(ps:/:)${PWD}}}
  local dest="./"

  # First try to find a folder with matching name (could potentially be a number)
  # Get parents (in reverse order)
  local parents
  local i
  for i in {$num_folders_we_are_in..2}
  do
    parents=($parents "$(echo $PWD | cut -d'/' -f$i)")
  done
  parents=($parents "/")
  # Build dest and 'cd' to it
  local parent
  1=`basename $1`
  foreach parent (${parents})
  do
    dest+="../"
    if [[ $1 == $parent ]]
    then
      cd $dest
      return 0
    fi
  done

  # If the user provided an integer, go up as many times as asked
  dest="./"
  if [[ "$1" = <-> ]]
  then
    if [[ $1 -gt $num_folders_we_are_in ]]
    then
      print -- "bd: Error: Can not go up $1 times (not enough parent directories)"
      return 1
    fi
    for i in {1..$1}
    do
      dest+="../"
    done
    cd $dest
    return 0
  fi

  # If the above methods fail
  print -- "bd: Error: No parent directory named '$1'"
  return 1
}
_bd () {
  # Get parents (in reverse order)
  local num_folders_we_are_in=${#${(ps:/:)${PWD}}}
  local i
  local -a parents
  for i in {$num_folders_we_are_in..2}
  do
    parents+="`echo $PWD | cut -d'/' -f$i`/"
  done
  parents+="/"
  _wanted directories expl 'parent directories' compadd -o nosort -a parents
}
compdef -a _bd bd

local color_codes
zstyle -s ':completion:*' list-colors color_codes
local dir_color=`echo "${color_codes}" | grep -o "\sdi=[0-9;]*\s" | xargs | cut -d "=" -f 2`
zstyle ':completion:*:complete:bd:*:directories' list-colors "=(#b)*(/)=${dir_color}="
