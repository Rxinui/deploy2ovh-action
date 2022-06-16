#!/bin/bash -e

##
# Deploy on a SSH server the current GitHub repository by using `git clone`
#
# Usage:
#    ./entrypoint.sh [pre-command] [post-command]
#
# Args:
#    pre-command: command to run before the deployment phase.
#    post-command: command to run after the deployment phase if previous phases are successful.
#
# Environments:
#    SSH_LOGIN_USER: SSH server login username
#    SSH_LOGIN_PASSWORD: SSH server login password
#    SSH_LOGIN_DOMAIN: SSH server login domain
#    [Optional] GIT_CLONE_BY: Git repository clone method. Value must be lowercase. Defaults to `https`
#    [Optional] TARGET_BRANCH: Git branch to clone/checkout. Defaults to `main`
#    [Optional] TARGET_DIRECTORY: Path where git repository will be cloned. Defaults to `~/`
#    [Optional] PROTECT_FILES: List of files to save before new deployment.
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

declare -A protected_files
_protected_files_path="/tmp/.protected-files/"
if [[ -n $PROTECT_FILES ]]; then
  saving_files_cmd="mkdir -p $_protected_files_path && cp -p -t /tmp -rf"
  log_info "Processing protect files..."
  declare -i total_files=`echo "$PROTECT_FILES" | wc -l`
  for i in `seq $total_files`
  do
    protect_file=`echo "$PROTECT_FILES" | cut -d$'\n' -f$i`
    if [[ -n $protect_file ]]; then
      log_info "Protect file #$count_real_files: $protect_file"
      saving_files_cmd+=" $TARGET_DIRECTORY/$protect_file"
      protected_files[`basename $TARGET_DIRECTORY/$protect_file`]=$TARGET_DIRECTORY/$protect_file
    fi
  done
  echo "Array keys: ${!protected_files[@]}"
  echo "Array values: ${protected_files[*]}"
  log_info "Protect files cmd: $saving_files_cmd"
fi
## END optional env variables

## BEGIN build commands
deploy_cmd+=" $TARGET_DIRECTORY"
clean_target_directory_cmd="rm -rf $TARGET_DIRECTORY"
built_ssh_cmd="$clean_target_directory_cmd && $deploy_cmd"
log_info "Command to execute on $SSH_LOGIN_DOMAIN as '$SSH_LOGIN_USER': \"$deploy_cmd\""
## END build commands

## BEGIN main program
# if [[ ${#protected_files[@]} -ne 0 ]]; then
#   log_info "Saving protected files: $saving_files_cmd"
#   sshpass -p "$SSH_LOGIN_PASSWORD" ssh -o StrictHostKeyChecking=no $SSH_LOGIN_USER@$SSH_LOGIN_DOMAIN "$saving_files_cmd"
# fi

# if [[ -n $1 ]]; then
#   log_info "Pre-command:"
#   echo "$1"
#   sshpass -p "$SSH_LOGIN_PASSWORD" ssh -o StrictHostKeyChecking=no $SSH_LOGIN_USER@$SSH_LOGIN_DOMAIN "$1"
# fi
# log_info "Deployment phase:"
# sshpass -p "$SSH_LOGIN_PASSWORD" ssh -o StrictHostKeyChecking=no $SSH_LOGIN_USER@$SSH_LOGIN_DOMAIN "$built_ssh_cmd"
# if [[ -n $2 ]]; then
#   _post_command+="cd $TARGET_DIRECTORY && $2"
#   log_info "Post-command:"
#   echo "$_post_command"
#   sshpass -p "$SSH_LOGIN_PASSWORD" ssh -o StrictHostKeyChecking=no $SSH_LOGIN_USER@$SSH_LOGIN_DOMAIN "$_post_command"
# fi

# if [[ ${#protected_files[@]} -ne 0 ]]; then
#   log_info "Retrieving protected files: "
#   sshpass -p "$SSH_LOGIN_PASSWORD" ssh -o StrictHostKeyChecking=no $SSH_LOGIN_USER@$SSH_LOGIN_DOMAIN ""
# fi
log_info "Done"
exit 0
## END main program
