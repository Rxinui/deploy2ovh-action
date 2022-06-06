#!/bin/bash -e

##
# Deploy on a SSH server the current GitHub repository by using `git clone` 
#
# Usage:
#    ./entrypoint.sh [Pre-command] [Post-command]
#
# Environments:
#    SSH_LOGIN_USER: SSH server login username
#    SSH_LOGIN_PASSWORD: SSH server login password
#    SSH_LOGIN_DOMAIN: SSH server login domain
#    [Optional] GIT_CLONE_BY: Git repository clone method. Value must be lowercase. Defaults to `https`
#    [Optional] TARGET_BRANCH: Git branch to clone/checkout. Defaults to `main`
#    [Optional] TARGET_DIRECTORY: Path where git repository will be cloned. Defaults to `~/`
#
##

## BEGIN functions

log_info() {
  echo -e "\e[32mINFO: $1\e[0m"
}

log_error() {
  echo -e "\e[31mERROR: $1\e[0m"
}

## END functions

## BEGIN mandatory env variables
if [[ -z $SSH_LOGIN_USER ]]; then
  log_error "missing mandatory env SSH_LOGIN_USER."
  exit 1000
fi
if [[ -z $SSH_LOGIN_DOMAIN ]]; then
  log_error "missing mandatory env SSH_LOGIN_DOMAIN."
  exit 1000
fi
if [[ -z $SSH_LOGIN_PASSWORD ]]; then
  log_error "missing mandatory env SSH_LOGIN_PASSWORD."
  exit 1000
fi
## END mandatory env variables

## BEGIN optional env variables
if [[ -n $GIT_CLONE_BY && $GIT_CLONE_BY == 'ssh' ]]; then
  log_info "Git clone by 'ssh'."
  git_clone_url=$(echo $GITHUB_EVENT_REPOSITORY | jq '.ssh_url')
else
  log_info "Git clone by 'https'."
  git_clone_url=$(echo $GITHUB_EVENT_REPOSITORY | jq '.clone_url')
fi

deploy_cmd="git clone"
if [[ -n $TARGET_BRANCH ]]; then
  deploy_cmd+=" -b $TARGET_BRANCH --single-branch"
fi
deploy_cmd+=" $git_clone_url"
if [[ -z $TARGET_DIRECTORY ]]; then
  TARGET_DIRECTORY="~/$($GITHUB_EVENT_REPOSITORY | jq '.name')"
fi
## END optional env variables

## BEGIN build commands
deploy_cmd+=" $TARGET_DIRECTORY"
clean_target_directory_cmd="rm -rf $TARGET_DIRECTORY"

_pre_command="$1"
if [[ -n $2 ]]; then
  _post_command+="cd $TARGET_DIRECTORY && $2"
fi

built_ssh_cmd="$clean_target_directory_cmd && $deploy_cmd"
log_info "Command to execute on $SSH_LOGIN_DOMAIN as '$SSH_LOGIN_USER': \"$deploy_cmd\""
## END build commands

log_info "Pre-command:
  $_pre_command"
sshpass -p "$SSH_LOGIN_PASSWORD" ssh -o StrictHostKeyChecking=no $SSH_LOGIN_USER@$SSH_LOGIN_DOMAIN "$_pre_command"
log_info "Deployment phase:"
sshpass -p "$SSH_LOGIN_PASSWORD" ssh -o StrictHostKeyChecking=no $SSH_LOGIN_USER@$SSH_LOGIN_DOMAIN "$built_ssh_cmd"
log_info "Post-command:
  $_post_command"
sshpass -p "$SSH_LOGIN_PASSWORD" ssh -o StrictHostKeyChecking=no $SSH_LOGIN_USER@$SSH_LOGIN_DOMAIN "$_post_command"
log_info "Done"
exit 0
