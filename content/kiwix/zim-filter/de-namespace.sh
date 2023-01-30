#!/bin/bash -x 
# dump param #1 (zim in CWD or absolute path) to dest (PREFIX/$NAME)
set -e

# Must supply ZIM
if [ $# -lt 2 ];then
   echo "Please supply absolute path of ZIM filename and the project name"
   exit 1
fi

# see if supplied filename works
if [ ! -f $1 ];then
   echo Could not open $1. Quitting . . .
   exit 1
fi

# for use in jupyter notebook, do not overwrite any tree contents
contents=$(ls $2|wc -l)
if [ $contents -ne 0 ];then
    echo "The $2/ is not empty. Delete if you want to repeat this step."
    exit 0
fi

# Delete the previous contents of zims
rm -rf $2
# Make directory
mkdir -p $2
echo "This de-namespace file reminds you that this folder will be overwritten?" > $2/de-namespace

zimdump dump --dir=$2 $1

# stop here to look around at the clean dumped format
# It looks like just living with the namespace layout imposed by zim spec might be a better strategy
#exit 0

# put all of the images back in their original places
mv $2/I/* $2
if [ -d I ];then
   rmdir I
fi

# Clip off the A namespace for html
cp -rp $2/A/* $2
cp -rp $2/-/* $2

if [ -d $2/A ];then
   rm -rf $2/A
fi

cd $2
for f in $(find .|grep -e html -e css); do
   sed -i -e's|../../../I/||g' $f
   sed -i -e's|../../I/||g' $f
   sed -i -e's|../I/||g' $f
   sed -i -e's|../../-/||g' $f
   sed -i -e's|../A/||g' $f
done
for f in $(find $2 -maxdepth 1 -type f );do
   sed -i -e's|../-/||g' $f
done
