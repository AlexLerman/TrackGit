# TrackGit

TrackGit is a ruby gem project that overlays your git commands to interface directly with an issue tracker if your choice. Currently only supports Github issue tracker.  

It provides a simple replacement for all git commands, defaulting to git when nothing different needs to happen.

```bash
tg createIssue "New Issue" # creates new issue and checks out a branch with the same name

tg checkout 15 # checkout issue number 15

tg listIssues # list of all issues
tg listIssues --mine # List all issues assigned to you

tg commit # automatically comments on issue being commited to. If using github issue tracker, will add issue number to bottom of commit message.

tg push || tg up # pushes changes to current branch.  

tg pull || tg down # pulls changes to current branch.  

tg finish # pushes commited changes, merges branch to master.
```
