git clone git@github.com:sq-gilles/sq-gilles-tuto_git.git gla

cd gla
ls -AR .
# a lot of files in .git

git config --local user.name gla_tuto
# change local user name to gla_tuto

git log
# display commits from current branch -> initial branch is main (for GitHub)

git log --oneline
# display compressed way

git config --local alias.mylog 'log --oneline'
# create command git mylog
git mylog


git log --oneline --format="%C(auto)%h %C(cyan)%<(16)%ah%C(auto) %C(blue)%<(16,trunc)%aN%C(auto) %>|(50)%m%d %<(80,trunc)%s %C(reset)"
#pretty display
git config --local alias.mylog 'log --oneline --format="%C(auto)%h %C(cyan)%<(16)%ah%C(auto) %C(blue)%<(16,trunc)%aN%C(auto) %>|(50)%m%d %<(80,trunc)%s %C(reset)"'

git branch dev_gla
git checkout dev_gla
# equivalent to git checkout -b dev_gla

touch src/page{1,2,3}.md
git status -u
git add :/
# not a skeptic smiley, this mean git root

git commit -m "create first three pages"
# create the commit

git config --local core.editor 'code --wait --reuse-window'
# last config, this use vscode as editor instead of nano

# edit page 1,2,3
git commit -a
# if empty: "Aborting commit due to empty commit message."

git commit -am "write corpus of page 1"
git commit -am "write corpus of page 2"

git checkout -b dev_other_gla main
# create a new branch dev_other_gla that point to main and switch to it

git mylog
# everthing has disapeared!
git mylog --all
# everything is still here, houra!


## other user
cd ..
git clone git@github.com:sq-gilles/sq-gilles-tuto_git.git gmi
git config --local user.name gmi_tuto

## edit src/draconomicon.md
git commit -am "append first line of the draconomicon"
git commit -am "write introduction to draconimicon"
## damn we commit on main, one wanted to commit on dev_gmi
git checkout -b dev_gmi

git branch main origin/main # error
git branch main origin/main -f # ok

git push origin dev_gmi
# the only correct way to push on origin

# switch to gla
git fetch
git mylog --all # ok but how are related gmi and gla commits ?
git mylog --all --graph
git config --local alias.adog 'mylog --all --graph'
# adog ? --all --decorate --oneline --graph


# switch to gmi
# for culture only: this simulate a pull request
git checkout main
git merge dev_gmi -m "Fake PullRequest #001"
# create a merge commit with message "Fake..." and left parent origin/main and right parent dev_gmi
git push origin main

# remove remote branch
git push origin :dev_gmi
# WTH?
git push origin dev_gmi:tralala
# Gneee!?
git push origin dev_gmi:dev_gmi # short for git push origin dev_gmi
git push origin :dev_gmi :tralala # clean remote
git branch -d dev_gmi # clean local branch

# back to gla
git fetch
# ok and then git pull 8-), no? No!
# just forget pull forever!
# wait origin/dev_gmi still here, why?
git fetch --prune # or -p


# let's do stuff before rebase
touch src/necronomicon.md
git commit -am "Start writing the neconomicon"
git rebase origin/main
# find the common ancestor and move the fork branch onto origin/main

git checkout dev_gla
git rebase origin/main
# same
# let's do a bit of magic now
git rebase -i dev_other_gla


git checkout -b dev_headlines dev_gla~3
# switch to new branch dev_headlines at commit 'create first three pages'
# dev_headlines dev_gla~3 means 3rd commit before dev_gla
for i in 1 2 3 4; do echo "# Head of page ${i}" > "src/page${i}.md"; done
git commit -am "append header to 4 pages"

# here it is the bag of bones.
# What we want: create a PR for dev_headlines with only
#  - 'create first three pages' and
#  - 'append header to 4 pages'
# rebased on origin/main

# many possibilities:
# why simple rebase will not work?
git rebase -i origin/main # ok already up to stream
git branch -f main origin/main
git checkout main
git merge dev_headlines # fail Start writing necronomicon has been merged
git reset origin/main --hard # move main to origin/main cleaning the mistakes

# git cherry-pick
git checkout dev_headlines
git branch tmp # save current branch pointer
git reset origin/main --hard # move dev_headline to origin/main
git cherry-pick c544a7a bc79df4 # should be commit named 'create first three pages' and 'append header to 4 pages'
git merge dev_headlines -m "Fake PullRequest #002 - dev_healine into main" --no-ff
git push origin main
git branch -d tmp # fail, tmp is not merge in the current branch
git branch -D tmp # ok
git branch -d dev_headlines

# Now merge corpus writes
git checkout dev_gla
git branch -m dev_corpus
git push origin dev_corpus
git rebase -i origin/main # remove everything cancel the rebase cherry-picked are skipped
git rebase -i --onto origin/master c544a7a^ dev_corpus
git rebase --abort
git rebase -i --onto origin/master c544a7a^ dev_corpus
# conflict with rebase HEAD is reversed from merge strategy
# in rebase HEAD corresponds to commit comming from origin/master
git add :/
git rebase --continue

#once complete
git rebase -i origin/main # with fixup page2
git rebase -i origin/main # with edit page1

git rebase -i origin/main # with edit page1 and 2 to split it again
git reset HEAD^ # unstage change

## edit gmi dev_corpus
git commit -am "continue by writing spells chapter"
## back to gla
git push origin dev_corpus -- force-with-lease # fail, never ever use --force
git fetch

git checkout main && git merge dev_corpus -m "Fake PullRequest #003 - dev_corpus into main" --no-ff

# now HW: clean the repos to make gmi_tuto's commit 
# 'Start writing the neconomicon' and 'continue by writing spells chapter'
# on a clean PR


# last but not least
# start repo novel on draconomicon continue
git stash
git checkout -b demo_draco 50a7eac # commit named 'Fake PullRequest #001'
git stash apply # apply without modification
# ok back to work
git checkout main
git stash pop
git commit -m "wip"
git push origin dev_gla
