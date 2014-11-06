#!/bin/bash

# taken from the example at:
# http://gohugo.io/tutorials/github_pages_blog

echo -e "\033[0;32mDeploying updates to GitHub...\033[0m"

# clear output
echo "*** clearing output"
rm output -rf

# refresh and remove subtree
echo "*** cloning output repo"
git clone https://github.com/galaktor/galaktor.github.io output
cd output
rm * -rf

# configure git credentials
echo "*** setting git credentials $GIT_NAME $GH_TOKEN"
git config credential.helper "store --file=.git/credentials"
echo "https://${GH_TOKEN}:@github.com" > .git/credentials
git config user.name $GIT_NAME
cd ..

# wipe output repo before build
echo "wiping output"
cd output
git rm * -rf
cd ..

# Set version from git revision count
base=$(cat ./layouts/partials/version.html)
rev=$(git log --oneline | wc -l)
new="$base.$rev"
echo "setting revision to $new"
echo "$new" > ./layouts/partials/version.html

# Build the project. 
echo "*** building html"
./hugo

# Add changes to git.
echo "*** adding changes to git"
cd output
git add -A

# Commit changes.
msg="rebuilding site `date`"
if [ $# -eq 1 ]
  then msg="$1"
fi
echo "*** commiting: $msg"
git commit -m "$msg"

# push subtree
echo "*** pushing to gh pages"
git push
