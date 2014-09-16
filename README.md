[![Gem Version](https://badge.fury.io/rb/gplan.svg)](http://badge.fury.io/rb/gplan)

## What is GPlan?

GPlan started out as a simple ruby script that parsed out ticket numbers
from any git log of the current branch compared to its production branch
and create puts together release notes

## Installation

    gem install gplan

# Create environment variables

This will be different on every OS, but for OSX, I did this...

    sudo echo "
    #for planbox
    export PLANBOX_EMAIL=<EMAIL_ADDRESS>
    export PLANBOX_TOKEN=<PASSWORD>
    export GITHUB_USERNAME=<GITHUB_USERNAME>
    export GITHUB_TOKEN=<GITHUB_TOKEN>" >> /etc/profile

# Configure Project

For any project you want to use this for, you will need to tell gplan what repository/branch to compare your current branch to.  To do this, create a `.gplan` file in the repository's root with `<repo_name>/<branch_name>`. If one isn't set, a default of `production/master` is used.

    echo "origin/master" > .gplan

OR

pass in a param that overrides this configuration. ie.. `gplan 98ih2h3583`

## Usage

1. cd to git project
2. checkout the branch that you wish to get release notes for
3. run `gplan`
4. you should now get a list of the pattern

```
ID:STATUS:TITLE:PROJECT_NAME:PROJECT_ALIAS:PR:TITLE
...
---- Unmatched PRs ----
...
PR:TITLE
```

Note: unmatched PRs are github pull requests that doesn't have a matching planbox story
