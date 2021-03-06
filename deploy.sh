#!/bin/bash

# based on the example at:
# http://gohugo.io/tutorials/github_pages_blog

echo "**********************"
echo "***** DEPLOYING *****"

echo "***** CLEAR OUTPUT *****"
rm output -rf

echo "***** CLONING TARGET REPO *****"
git clone https://github.com/galaktor/galaktor.github.io output
cd output
rm * -rf

echo "***** SET GIT CREDENTIALS *****"
git config credential.helper "store --file=.git/credentials"
echo "https://${GH_TOKEN}:@github.com" > .git/credentials
git config user.name $GIT_NAME
git config user.email "galaktor@gmx.de"
cd ..

echo "***** WIPING TARGET DIR *****"
cd output
git rm * -rf
cd ..

echo "***** SET VERSION IN HTML *****"
cd output
rev=$(git rev-list HEAD --count --all)
cd ..
rev=$((rev + 1))
base=$(cat ./layouts/partials/version.html)
new="$base.$rev"
echo "***** NEW REVISION: $new *****"
echo "$new" > ./layouts/partials/version.html

# Build the project. 
echo "***** BUILD HTML WITH HUGO *****"
./hugo

# Add changes to git.
echo "***** ADD NEW OUTPUT TO TARGET REPO *****"
cd output
git add -A

# Commit changes.
msg="rebuilding site `date`"
if [ $# -eq 1 ]
  then msg="$1"
fi
echo "***** COMMITTING: $msg *****"
git commit -m "$msg"

# push subtree
echo "***** PUSH TO TARGET REPO *****"
git push
