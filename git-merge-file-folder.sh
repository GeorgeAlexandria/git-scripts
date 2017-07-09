# merge file from one repository to folder from another repository

# $1 git path server `from` repositoy
# $2 `from` repository name
# $3 local path `to` repository
# $4 `from` folder name
# $5 file name
# $6 `to` folder name 
# [$7] `from` branch by default `master`
# [$8] `to` branch by default `master`

fromBranch=${6:-master}
toBranch=${7:-master}

curDir=$(pwd)
cd "$3"

git remote add -f tempRepo $1$2.git
git checkout -b tempBranch --no-track tempRepo/fromBranch

git filter-branch --prune-empty --subdirectory-filter $4 tempBranch

# Remove ref if exists
git update-ref -d refs/original/refs/heads/tempBranch

# --ignore-unwathc will works if the supplied argument isn't found and won't work in the case that doesn't have argument supplied. 
# So you can use lines below in this case.  

# deleter='git ls-tree -r --name-only --full-tree "$GIT_COMMIT" | grep -v "'$5'" | 
# tr "\n" "\0" | xargs --no-run-if-empty --null git rm --cached -r --ignore-unmatch'
deleter='git ls-tree -r --name-only --full-tree "$GIT_COMMIT" | grep -v "'$5'" | 
tr "\n" "\0" | xargs -0 git rm --cached -r --ignore-unmatch'
git filter-branch -f --prune-empty --index-filter "$deleter" HEAd

git update-ref -d refs/original/refs/heads/branchFromRepo

# --prune-empty not move merge empty commit, so you should set a range of commits to filter (70c98285..HEAD)
git filter-branch --prune-empty -f --index-filter 'git ls-files -s | sed "s-\t-&'$6'/-" |
GIT_INDEX_FILE=$GIT_INDEX_FILE.new \
git update-index --index-info &&
mv $GIT_INDEX_FILE.new $GIT_INDEX_FILE' HEAD

git update-ref -d refs/original/refs/heads/tempBranch
git remote rm tempRepo

git checkout toBranch            
git merge tempBranch --allow-unrelated-histories -m "Merge file $5 from $4"
git branch -D tempBranch

#git push origin toBranch

cd $curDir