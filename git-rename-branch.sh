#$1 current branch name
#$2 new branch name

git branch -m $1 $2                 # Rename branch locally
git push origin :$1                 # Delete the current branch
git push --set-upstream origin $2   # Push the new branch, set local branch to track the new remote