#!/bin/bash

# sync_mappy_fork - A script to Mappy fork of mbgl with Mapbox repository

echo "Checking remote upstream"
git remote -v | grep 'upstream' &> /dev/null || git remote add upstream https://github.com/mapbox/mapbox-gl-native-ios.git
git remote update

echo "Fetching upstream master"
git fetch upstream master

echo "Updating local master"
git checkout master --recurse-submodules
git pull origin master --rebase

echo "Merging remote master with local one"
git merge upstream/master

echo "Pushing updates"
if [[ $1 == "debug" ]]; then
    echo "Debug, no push done"
    exit
fi
git push origin master
git push --tags

echo "Back to mappy branch"
git checkout mappy 
git submodule update --init
git reset --hard --recurse-submodules
