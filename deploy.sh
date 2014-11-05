#!/bin/bash

# taken from the example at:
# http://gohugo.io/tutorials/github_pages_blog

echo -e "\033[0;32mDeploying updates to GitHub...\033[0m"

# configure git credentials
echo "setting git credentials $GIT_NAME $GH_TOKEN"
git config credential.helper "store --file=.git/credentials"
echo "https://${GH_TOKEN}:@github.com" > .git/credentials
git config user.name $GIT_NAME

# refresh and remove subtree
git remote add out https://github.com/galaktor/galaktor.github.io
git subtree pull --prefix=output out master

# clear output
#rm -rf output

# Build the project. 
echo "building html"
./hugo

# Add changes to git.
echo "adding changes to git"
git add output

# Commit changes.
msg="rebuilding site `date`"
if [ $# -eq 1 ]
  then msg="$1"
fi
echo "commiting: $msg"
git commit -m "$msg"

# push subtree
echo "pushing subtree to gh pages"
git subtree push --prefix=output out master
