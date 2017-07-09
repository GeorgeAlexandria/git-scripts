# merge folder from one repository to folder from another repository

# $1 git path server `from` repositoy
# $2 `from` repository name
# $3 local path `to` repository
# $4 `from` folder name 
# $5 `to` folder name 
# [$6] `from` branch by default `master`
# [$7] `to` branch by default `master`

fromBranch=${6:-master}
toBranch=${7:-master}

curDir=$(pwd)
cd "$3"

git remote add -f tempRepo $1$2.git
git checkout -b tempBranch --no-track tempRepo/fromBranch

git filter-branch --prune-empty --subdirectory-filter $4 tempBranch

# Remove ref if exists
git update-ref -d refs/original/refs/heads/tempBranch

git filter-branch --index-filter 'git ls-files -s | sed "s-\t-&'$5'/-" |
GIT_INDEX_FILE=$GIT_INDEX_FILE.new \
git update-index --index-info &&
mv $GIT_INDEX_FILE.new $GIT_INDEX_FILE' HEAD

git update-ref -d refs/original/refs/heads/tempBranch
git remote rm tempRepo

git checkout toBranch            
git merge tempBranch --allow-unrelated-histories -m "Merge folder $4"
git branch -D tempBranch

#git push origin toBranch

cd $curDir