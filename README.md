[![Gem Version](https://badge.fury.io/rb/gplan.svg)](http://badge.fury.io/rb/gplan)

## What is GPlan?

GPlan started out as a simple ruby script that parsed out ticket numbers
from any git log of the current branch compared to its production branch
and puts together release notes

As of right now, it does this by combining Github Pull Requests, Github Issues and Planbox Stories.

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
PR:TITLE:ISSUES:MILESTONE
...
---- Matched Planbox Stories ----
...
ID:STATUS:TITLE:PROJECT_NAME:PROJECT_ALIAS:PR:TITLE
```

Note: the first table is unmatched PRs and are github pull requests that doesn't have a matching planbox story

### HTML Release notes

To ouput release notes as HTML

    gplan -h

They will look something like this...

![image](https://cloud.githubusercontent.com/assets/2390653/7863992/7dd34df2-052d-11e5-80ef-77c2cef5b658.png)


## Dependency

Gplan will detect dependencies based on a Github PR. It will find it using this logic

1. Does the PR contain a markup header (ie. some number of #'s) followed by some variation of the word dependency?

  example:
  ```
  ## Dependencies
  you must run a rake task
  ```
Note that this will include everything from the '##' to the next '##' or the end of the PR body

2. Does the PR contain a line that starts with "depends on"? then that line will be included

  example:
  ```
  Depends on #123
  ```

3. Does the PR contain the label "Has Dependency"?

## Tests

### Setup

    bundle

To run tests:

    rake test

or just

    rake
