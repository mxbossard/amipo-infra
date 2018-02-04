#! /bin/sh

scope="--local"

# Productive alias
git config $scope alias.s 'status'

git config $scope alias.who 'shortlog -sne'
git config $scope alias.changes 'diff --name-status'
git config $scope alias.dic 'diff --cached'
git config $scope alias.d 'diff --stat'

git config $scope alias.hist 'log --pretty=oneline --abbrev-commit --graph --decorate' # Condensed history
git config $scope alias.lc '!git hist ORIG_HEAD.. --stat --no-merges' # Changes since last pull

git config $scope alias.amend 'commit --amend' # Edit last commit
git config $scope alias.undo 'git reset --soft HEAD^' # Cancel last commit

# Config for submodules
git config $scope diff.submodule log
git config $scope fetch.recurseSubmodules on-demand
git config $scope status.submoduleSummary true

git config $scope alias.spull '__git_spull() { git pull "$@" && git submodule sync --recursive && git submodule update --init --recursive; }; __git_spull'
git config $scope alias.spush 'push --recurse-submodules=on-demand'

