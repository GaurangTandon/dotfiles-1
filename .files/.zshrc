export ZSH="/home/yog/.oh-my-zsh"

ZSH_THEME="agnoster"

plugins=(
    vi-mode
    zsh-syntax-highlighting
    zsh-autosuggestions
    docker
    docker-compose
    kubectl
)

source $ZSH/oh-my-zsh.sh

# load aliases
source ~/.aliases

# fasd
{ if [ "$ZSH_VERSION" ] && compctl; then # zsh
    eval "$(fasd --init posix-alias zsh-hook zsh-ccomp zsh-ccomp-install \
      zsh-wcomp zsh-wcomp-install)"
  elif [ "$BASH_VERSION" ] && complete; then # bash
    eval "$(fasd --init posix-alias bash-hook bash-ccomp bash-ccomp-install)"
  else # posix shell
    eval "$(fasd --init posix-alias posix-hook)"
  fi
} >> "/dev/null" 2>&1

ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=4'

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

if [ $TILIX_ID ] || [ $VTE_VERSION ]; then
    source /etc/profile.d/vte.sh
fi

# pip zsh completion start
function _pip_completion {
  local words cword
  read -Ac words
  read -cn cword
  reply=( $( COMP_WORDS="$words[*]" \
             COMP_CWORD=$(( cword-1 )) \
             PIP_AUTO_COMPLETE=1 $words[1] ) )
}
compctl -K _pip_completion pip3
# pip zsh completion end

# automatically send SIGCONT to disown'd child
setopt AUTO_CONTINUE

[[ $commands[kubectl] ]] && source <(kubectl completion zsh)
complete -F __start_kubectl kk

[ -s "$NVM_DIR/nvm.sh" ] && source "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && source "$NVM_DIR/bash_completion"

[[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm" # Load RVM into a shell session *as a function*

export PYTHONSTARTUP=~/.pyrc

PERL5LIB="$HOME/perl5/lib/perl5${PERL5LIB:+:${PERL5LIB}}"; export PERL5LIB;
PERL_LOCAL_LIB_ROOT="$HOME/perl5${PERL_LOCAL_LIB_ROOT:+:${PERL_LOCAL_LIB_ROOT}}"; export PERL_LOCAL_LIB_ROOT;
PERL_MB_OPT="--install_base \"$HOME/perl5\""; export PERL_MB_OPT;
PERL_MM_OPT="INSTALL_BASE=$HOME/perl5"; export PERL_MM_OPT;

export FZF_DEFAULT_COMMAND="rg --hidden --files"

export MALMO_XSD_PATH="/home/yog/prog/god-birdge/MalmoPlatform/Schemas"
export JUPYTERLAB_DIR=$HOME/.local/share/jupyter/lab

add-zsh-hook -Uz chpwd (){ [ -f .env ] && source .env; [ -d venv ] && source venv/bin/activate }

export HEROKU_ORGANIZATION="aicrowd-rails-devs"
