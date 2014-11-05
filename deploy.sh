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
echo "setting git credentials $GH_NAME $GH_TOKEN"
git config credential.helper "store --file=.git/credentials"
echo "https://${GH_TOKEN}:@github.com" > .git/credentials
git config user.name $GH_NAME

# Add changes to git.
echo "adding changes to git"
git add .

# Commit changes.
msg="rebuilding site `date`"
if [ $# -eq 1 ]
  then msg="$1"
fi
echo "commiting: $msg"
git commit -m "$msg"

# push subtree
echo "pushing subtree to gh pages"
git subtree push --prefix=output https://github.com/galaktor/galaktor.github.io master
