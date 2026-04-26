# here are some zsh helper functions / aliases for making your CLI operations with Git, GCP etc easier.
# paste them into your .zshrc, run "source $your-zshrc-path" and see what you think.

plugins=(git fzf-zsh-plugin zsh-autosuggestions zsh-syntax-highlighting)
source $ZSH/oh-my-zsh.sh
source $ZSH—CUSTWp1ugins/zsh-syntax-high1ighting/zsh-syntax-hightighting.zsh
source $ZSH—CUST04/p1ugins/zsh-autosuggestions/zsh-autosuggestions.zsh

export GITHUB_ORG="https://your.github.org"

###########
# gcloud 
###########

# decodes a JWT (java web token) that's in base64, such as a gcloud auth bearer token. useful if you want to investigate auth attempts.
function jwt-decode(){
  jq -R 'split(".") |.[0:2] | map(gsub("-"; "+") | gsub("_"; "/") | gsub("%3D"; "=") | @base64d) | map(fromjson)' <<< $1
}

function gcca() {
  gcloud config configurations activate $1
  gcloud auth login
}

function gal() {
  gcloud auth login
}
function gaadl() {
  gcloud auth application-default login
}

# one azure one for if you use entra ID
function azl() {
  az login --allow-no-subscriptions
}

#####
# git
#####

# gacp = git add, commit, push
# Creates PR if push is successful and the output prompts user to create one
function gacp() {
  git add -A
  git commit -m $1
  # Capture output and display it
  push_output=$(git push 2>&1)
  echo "$push—output"
  # Check if output contains PR suggestion
  if echo "$push_output" | grep -q "Create a pull request" ; then
    cpr
  fi
}

# cpr = create pull request
function cpr() {
  open "$GITHUB_ORG/$(git config --get remote.origin.url | sed 's/\ git$//g' | sed 's/$GITHUB_ORG\///g')/compare/$(git rev-parse --abbrev-ref HEAD)?expand=1"
}

# gecp = git empty-commit push
function gecp() {
  git commit --allow-empty -m "$1"
  git push
}

function gcfp(){
  git fetch upstream
  git checkout $(git branch --list master main | awk '{print $NF}')
  git merge upstream/$(git branch --list master main | awk '{print $NF}')
}

function gchp(){
  branch=$(git branch --list master main | awk '{print $NF}')
  git fetch origin
  git checkout $branch
  git merge origin/$branch
}

function gchb(){
  git checkout -b "$1"
}

function tfm(){
  terrafom fmt -recursive
}

function gsu() {
  git branch --set-upstream-to origin
}

function gchk(){
  git checkout "$1"
}

function gc() {
  gcloud "$@"
}

function gpl() {
  git pull origin "$1"
}

function grau() {
  git remote add upstream
}

function gsfp() {
  branch=$(git branch --list master main | awk '{print $NF}')
  git stash
  git checkout $branch
  git fetch origin
  git pull
}

function gsp() {
  git stash pop
}
