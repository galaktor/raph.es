#!/bin/bash

# taken from the example at:
# http://gohugo.io/tutorials/github_pages_blog

echo -e "\033[0;32mDeploying updates to GitHub...\033[0m"

# clear output
rm -r output

# Build the project. 
./hugo

# configure git credentials
git config credential.helper "store --file=.git/credentials"
echo "https://${GH_TOKEN}:@github.com" > .git/credentials
git config user.name $GH_NAME

# Add changes to git.
git add .

# Commit changes.
msg="rebuilding site `date`"
if [ $# -eq 1 ]
  then msg="$1"
fi
git commit -m "$msg"

# push subtree
git subtree push --prefix=output https://github.com/galaktor/galaktor.github.io master
