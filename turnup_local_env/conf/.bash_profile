export OPT=$HOME/opt
export OPT_BIN=$OPT/bin
export OPT_APP=$OPT/app
export CLANG_HOME=$OPT_APP/clang
export CLANG_BIN=$CLANG_HOME/bin
export CARGO_BIN=$HOME/.cargo/bin
export PATH=$PATH:$OPT_BIN:$CLANG_BIN:$CARGO_BIN

# INTERACTIVE_BASHPID_TIMER="/tmp/${USER}.START.$$"

# PS0='$(echo $SECONDS > "$INTERACTIVE_BASHPID_TIMER")'

# function _update_ps1() {
#   local __ERRCODE=$?

#   local __DURATION=0
#   if [ -e $INTERACTIVE_BASHPID_TIMER ]; then
#     local __END=$SECONDS
#     local __START=$(cat "$INTERACTIVE_BASHPID_TIMER")
#     __DURATION="$(($__END - ${__START:-__END}))"
#     rm -f "$INTERACTIVE_BASHPID_TIMER"
#   fi

#   PS1=`powerline-go -modules cwd,user,duration -duration $__DURATION -cwd-max-depth 4 -cwd-max-dir-size 20 -error $__ERRCODE -shell bash`
# }

# if [ "$TERM" != "linux" ] && [ -f "$OPT_BIN/powerline-go" ]; then
#   PROMPT_COMMAND="_update_ps1; $PROMPT_COMMAND"
# fi



export PATH="$HOME/.cargo/bin:$PATH"

# Path to pip3 bin.
export PATH=$PATH:$HOME/.local/bin:
