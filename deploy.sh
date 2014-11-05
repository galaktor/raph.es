#!/bin/bash

# taken from the example at:
# http://gohugo.io/tutorials/github_pages_blog

echo -e "\033[0;32mDeploying updates to GitHub...\033[0m"

# clear output
rm -r output

# Build the project. 
echo "building html"
./hugo

# configure git credentials
echo "setting git credentials $GIT_NAME $GH_TOKEN"
git config credential.helper "store --file=.git/credentials"
echo "https://${GH_TOKEN}:@github.com" > .git/credentials
git config user.name $GIT_NAME

# Add changes to git.
echo "adding changes to git"
git add -A

# Commit changes.
msg="rebuilding site `date`"
if [ $# -eq 1 ]
  then msg="$1"
fi
echo "commiting: $msg"
git commit -m "$msg"

# refresh then push subtree
git remote add out https://github.com/galaktor/galaktor.github.io
git subtree pull --prefix=output master out master
echo "pushing subtree to gh pages"
git subtree push --prefix=output out master
