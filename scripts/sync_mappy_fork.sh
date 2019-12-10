#!/bin/bash

# sync_mappy_fork - A script to Mappy fork of mbgl with Mapbox repository

git remote -v | grep 'upstream' &> /dev/null || git remote add upstream https://github.com/mapbox/mapbox-gl-native-ios.git
git remote update
#git fetch upstream master
git checkout master
git pull origin master --rebase
git merge upstream/master
git push origin master
git push --tags
git checkout -
