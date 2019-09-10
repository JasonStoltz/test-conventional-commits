minor_branch_name=`git branch --list $minor_branch_name`
if [ -z git branch --list $minor_branch_name ]
then
   echo "
   A thing
   another thing"
else
   echo "
   A thing
   Another thing"
fi
