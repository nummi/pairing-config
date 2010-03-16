function pushed() {
  if [ $@ ]; then
    git cherry -v origin/$@
  else
    git cherry -v origin/$(git_branch_name)
  fi
}

function git_branch_name() {
  git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/\1/'
}

function is_working_directory_dirty() {
 if current_git_status=$(git status 2> /dev/null | grep --regex="deleted\|modified\|Untracked" 2> /dev/null); then
   echo "⚡"
 else
   echo ''
 fi
}

function unpushed() {
  git cherry -v origin/$(git_branch_name) 2>/dev/null
}

function need_push () {
  if [[ $(unpushed) == "" ]]
  then
    echo " "
  else
    echo "%{\e[0;33m%} ↑%{\e[0m%}"
  fi
}


function gitdays {
  git log --author=Pairing --reverse --since="$@ days ago" --pretty="format:%n%Cgreen%cd%n%n%s%n%b%n---------------------------------------------" 
}

# accepts a css file and compacts the delcarations to one line
function css_compact {
  cat $@ | css2sass | sass -t compact > $@
}

# hamlizes whatever is on the clipboard
function pbhaml {
  pbpaste | html2haml | pbcopy
}

function md {
  markdown.pl $@ > /tmp/generated_by_markdown.html; open /tmp/generated_by_markdown.html
}

function set_prompt() {
  export PS1='%2/ ~ '

  branch_name=$(git_branch_name)
  if [ -n "$branch_name" ]; then
    export PS1='%1~%{$reset_color$bold_color$fg[green]%}%{$reset_color$fg[green]%} ($branch_name)%{$reset_color%} ~ '
    export RPS1="%{$fg[magenta]%}$(is_working_directory_dirty)%{$fg[yellow]%}$(need_push)%{$reset_color%}"
  fi
}

function railstags() {
  rtags --vi -a -f tags -R app -R lib -R script -R spec
}

function push_configs() {
  pushd
  cd ~/projects/config
  git add . && git commit -a && git push
  popd
}

function pull_configs() {
  pushd
  cd ~/projects/config
  git pull
  popd
}

function vack() {
  ack -l $* | xargs mvim -p
}

function reload! {
  echo Restarting Passenger...
  touch tmp/restart.txt
}

function internet\? {
  (ping -c 3 -t 3 google.com >/dev/null 2>&1 && echo 'yep') || echo 'nope'
}