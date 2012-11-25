#!/bin/sh
#(C)Copyright 2012 by Eric S. Raymond
# Permission is specifically granted to redistribute under the license of git.

test_description="Round-trip test for git-weave."

PATH=$PATH:`dirname $PWD`
export PATH

REPO=/tmp/testrepo$$
rm -fr -fr $REPO; mkdir $REPO; cd $REPO

# Commit 1 on master
git init -q
cat >README <<EOF
This is some sample content.
EOF
git add README
git commit -q -a -m "This is some sample content"

# Commit 2 on master
cat >README <<EOF
Master modification of the sample file
EOF
git commit -q -a -m "Master modification of the sample file"

# Commit 3 on samplebranch
git branch samplebranch
git checkout -q samplebranch
cat >README <<EOF
Hack the README so it has different content on the branch.
EOF
git commit -q -a -m "Hack the README so it has different content on the branch."

# Commit 4 on master
git checkout -q master
cat >README <<EOF
Further modify the sample content.
EOF
git commit -q -a -m "Further modify the sample content."

# Commit 5 on samplebranch
git checkout -q samplebranch
cat >README <<EOF
The branch content continues to evolve in a different direction.
EOF
git commit -q -a -m "The branch content continues to evolve in a different direction."

# Ugh.  What resets come out in a stream dump. and in what order, is 
# fairly random.  This magic number tells us how to trim the test logs
# so we're looking at their real content.  Set it to a high-out-of-sight
# value when modifying the test repo generation.
TRIM=70

# With the example repo built, we can begin testing

REPO_STREAM=/tmp/repo_stream_$$
RAVELED=/tmp/raveled$$
WOVEN=/tmp/woven$$
WOVEN_STREAM=/tmp/woven_stream_$$
rm -fr -fr $WOVEN $WOVEN_STREAM $RAVELED #$RAVELED_STREAM

cd /tmp

echo "1..5"

# Dump the repo state for later comparison
if { cd $REPO; git fast-export --all | head -$TRIM >$REPO_STREAM; }
then
    echo "ok 1 - Streaming of test repo succeeded"
else
    echo "not ok 1 - Streaming of test repo failed."
fi

# Unravel the repo
if { git-weave -q $REPO $RAVELED; }
then
    echo "ok 2 - First ravel operation succeeded."
else
    echo "not ok 2 - First ravel operation failed."
    exit 1
fi

# Reweave the repo
if { git-weave -q $RAVELED $WOVEN; }
then
    echo "ok 3 - First weave operation succeeded."
else
    echo "not ok 3 - Weave operation failed."
    exit 1
fi

# Dump its state for comparison with the repo stream
if { cd $WOVEN; git fast-export --all | head -$TRIM >$WOVEN_STREAM; }
then
    echo "ok 4 - Streaming of rewoven repo succeeded"
else
    echo "not ok 4 - Streaming of rewoven repo failed."
fi

# Now compare the original history with the rewoven version
if { diff $REPO_STREAM $WOVEN_STREAM; }
then
    echo "ok 5 - Rewoven history matches original"
else
    echo "not ok 5 - Rewoven history doesn't match original"
fi

trap "rm -fr $REPO $WOVEN $WOVEN_STREAM; exit 0" 0 1 2 15
