## What is GPlan?

GPlan started out as a simple ruby script that parsed out ticket numbers
from any git log of the current branch compared to its production branch
and create puts together release notes

## Setup

    gem build gplan.gemspec
    gem install gplan-0.0.0.gem

or to install globally

    rvm @global do gem install gplan-0.0.0.gem

