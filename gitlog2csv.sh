
baseDir="${pwd}"                                                                                                                                                                       
repoDir='/home/rajiv/gitNinja/sampleRepos/spring-data-keyvalue-examples'                                                                                                                       
#cmd_gitlog=' git log --remotes=origin --numstat --pretty=oneline -2 --format="AuthorName:%aN%nAuthorEmail:%aE%nAuthorDate:%aI"'
echo "RepoDir=${repoDir}"
echo "baseDir=${baseDir}"

cd $repoDir
echo "Changed dir to ${pwd}"

#echo "command to execute : $cmd_gitlog"
#logOutput="`$cmd_gitlog`"


rm -f temp.log

git log --remotes=origin --numstat --pretty=oneline --date=short -2 --format="AuthorName:%aN%nAuthorEmail:%aE%nAuthorDate:%ad%nSubject:%s" | grep -v -e ^[[:space:]]*$ > temp.log

isDone=false
until $isDone
do
    read line || isDone=true
 
    echo "--------------------------------------"
    if [[ $line =~ ^[[:alpha:]] ]]; then
      echo "alpha : $line"
      key=`echo $line | sed 's/:.*//'`
      echo "key[$key]"
      value=`echo $line | sed 's/^[^:]*://'`
      echo "value[$value]"
    elif [[ $line =~ ^[[:digit:]] ]]; then
      echo "digit : $line"
      locAdded=$(echo "$line" | cut -d$'\t' -f1)
      echo "locAdded[$locAdded]"
      locDeleted=$(echo "$line" | cut -d$'\t' -f2)
      echo "locDeleted[$locDeleted]"
      srcFile=$(echo "$line" | cut -d$'\t' -f3)
      echo "srcFile[$srcFile]"
      srcFileType=$(echo "$srcFile" | sed 's/.*\.//')
      echo "srcFileType[$srcFileType]"
    else
      echo "@Rajiv : invalid line"
    fi
done < temp.log


echo "-----------  --------------  -----------  -----------  -------------"
echo "$logOutput"

exit 0

