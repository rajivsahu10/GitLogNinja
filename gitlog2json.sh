
#set -xv

baseDir="$(pwd)"                                                                                                                                                                       
repoDir='/home/rajiv/gitNinja/sampleRepos/spring-data-keyvalue-examples'
commitsJsonFile="${baseDir}/commits.json"
#cmd_gitlog=' git log --remotes=origin --numstat --pretty=oneline -2 --format="AuthorName:%aN%nAuthorEmail:%aE%nAuthorDate:%aI"'
echo "RepoDir=${repoDir}"
echo "baseDir=${baseDir}"

#########  functions ##########

addCurrentCommit(){
    #params=$1
    #diffStats=$2
    #commitCount=$3
    echo " commit count = $commitCount"
    echo "commit log path = $commitsJsonFile"
     
    if [ " $commitCount" -gt 1 ]; then
        printf ", \n{ " >> $commitsJsonFile
    else 
        printf "\n{ " >> $commitsJsonFile 
    fi

    firstEntry=0
    for entryLine in "${currentCommitParams[@]}"
    do
       #echo "Functin loop 1 : $entryLine"
       key=$( echo $entryLine | sed 's/:.*//' | sed 's/\"//g' )
       #echo "key[$key]"
       value=$( echo $entryLine | sed 's/^[^:]*://' | sed 's/\"//g' )
       #echo "value[$value]"
       if [ "$firstEntry" -eq 0 ]; then
           ((++firstEntry))
           printf "\n\t\"$key\" : \"$value\"" >>  $commitsJsonFile
       else
           printf ",\n\t\"$key\" : \"$value\"" >> $commitsJsonFile
       fi
    done
   
    firstEntry=0
    printf "\n\t\"diffStats\" : [ " >> $commitsJsonFile
    for diffEntry in "${currentCommitDiffStats[@]}"
    do 
        echo "digit : $diffEntry"
        locAdded=$(echo "$diffEntry" | cut -d$'\t' -f1)
        #echo "locAdded[$locAdded]"
        locDeleted=$(echo "$diffEntry" | cut -d$'\t' -f2)
        #echo "locDeleted[$locDeleted]"
        srcFile=$( echo "$diffEntry" | cut -d$'\t' -f3 | sed 's/\"//g' )
        #echo "srcFile[$srcFile]"
        srcFileType=$(echo "$srcFile" | sed 's/.*\.//')
        #echo "srcFileType[$srcFileType]"  
        
        
        if [ "$firstEntry" -eq 0 ]; then
            ((++firstEntry))
            printf "\n\t\t{" >>  $commitsJsonFile
        else
            printf ",\n\t\t{" >> $commitsJsonFile
        fi
        
        printf "\n\t\t\"locAdded\" : \"$locAdded\"," >> $commitsJsonFile 
        printf "\n\t\t\"locDeleted\" : \"$locDeleted\"," >> $commitsJsonFile
        printf "\n\t\t\"srcFile\" : \"$srcFile\"," >> $commitsJsonFile
        printf "\n\t\t\"srcFileType\" : \"$srcFileType\"" >> $commitsJsonFile
        printf "\n\t\t } " >> $commitsJsonFile
        
    done
    # end of diff array
    printf "\n\t\t ]" >> $commitsJsonFile
    
    # end of response
    printf "} " >> $commitsJsonFile
}


########### main flow  ##############

cd $repoDir
echo "Changed dir to $(pwd)"

#echo "command to execute : $cmd_gitlog"
#logOutput="`$cmd_gitlog`"


rm -f temp.log
rm -f $commitsJsonFile
git log --remotes=origin --numstat --pretty=oneline --date=short -2 --format="AuthorName:%aN%nAuthorEmail:%aE%nAuthorDate:%ad%nhash:%h%nSubject:%s" | grep -v -e ^[[:space:]]*$ > temp.log

commitsList=()
currentCommitParams=()
currentCommitDiffStats=()
commitCount=0

isDone=false
until $isDone
do
    read line || isDone=true
    
    if [[ $line =~ ^[[:alpha:]] ]]; then
      #echo "alpha : $line"
      key=$( echo $line | sed 's/:.*//' | sed 's/\"//g' )
      if [ "$key" == "AuthorName" ]; then
          if [ "$commitCount" -gt 0 ]; then
              addCurrentCommit $currentCommitParams $currentCommitDiffStats $commitCount
              currentCommitParams=()
              currentCommitDiffStats=()
          fi
          ((commitCount++))
      fi
      currentCommitParams+=("$line")                  

    elif [[ $line =~ ^[[:digit:]] ]]; then
      currentCommitDiffStats+=("$line")
    else
      echo "@Rajiv : invalid line"
    fi
done < temp.log

addCurrentCommit $currentCommitParams $currentCommitDiffStats $commitCount

# Removing temp.log file
rm -f temp.log


exit 0

