
#set -xv


#########  functions ##########

addCurrentCommit(){
    #params=$1
    #diffStats=$2
    #commitCount=$3
    
    #echo " commit count = $commitCount"
    #echo "commit log path = $commitsJsonFile"
     
    printf "{ " >> $commitsJsonFile

    #firstEntry=0
    for entryLine in "${currentCommitParams[@]}"
    do
       #echo "Functin loop 1 : $entryLine"
       key=$( echo $entryLine | sed 's/:.*//' | sed 's/\"//g' )
       #echo "key[$key]"
       value=$( echo $entryLine | sed 's/^[^:]*://' | sed 's/\"//g' )
       #echo "value[$value]"
       
       printf " \"$key\" : \"$value\"," >>  $commitsJsonFile
        
       ## don't need the below block anymore as the diffStats entry
       ## is always going to be there, even when the diff is empty
       ## as it is an array
       #if [ "$firstEntry" -eq 0 ]; then
       #    ((++firstEntry))
       #    printf "\n\t\"$key\" : \"$value\"" >>  $commitsJsonFile
       #else
       #    printf ",\n\t\"$key\" : \"$value\"" >> $commitsJsonFile
       #fi
    done

    printf " \"repoName\" : \"$repoName\"," >>  $commitsJsonFile  
       
    firstEntry=0
    printf " \"diffStats\" : [ " >> $commitsJsonFile
    for diffEntry in "${currentCommitDiffStats[@]}"
    do 
        #echo "digit : $diffEntry"
        locAdded=$(echo "$diffEntry" | cut -d$'\t' -f1)
        #echo "locAdded[$locAdded]"
        locDeleted=$(echo "$diffEntry" | cut -d$'\t' -f2)
        #echo "locDeleted[$locDeleted]"
        srcFile=$( echo "$diffEntry" | cut -d$'\t' -f3 | sed 's/\"//g' | sed 's/^[^\/]*\///' | sed 's/\//./g' )
        #echo "srcFile[$srcFile]"
        srcFileType=$(echo "$srcFile" | sed 's/.*\.//' )
        #echo "srcFileType[$srcFileType]"  
        
        
        if [ "$firstEntry" -eq 0 ]; then
            ((++firstEntry))
            printf " {" >>  $commitsJsonFile
        else
            printf ", {" >> $commitsJsonFile
        fi
        
        printf " \"locAdded\" : \"$locAdded\"," >> $commitsJsonFile 
        printf " \"locDeleted\" : \"$locDeleted\"," >> $commitsJsonFile
        printf " \"srcFile\" : \"$srcFile\"," >> $commitsJsonFile
        printf " \"srcFileType\" : \"$srcFileType\"" >> $commitsJsonFile
        printf " } " >> $commitsJsonFile
        
    done
    # end of diff array
    printf " ]" >> $commitsJsonFile
    
    # end of response
    printf " } \n" >> $commitsJsonFile
}

printError(){
  RED='\033[0;31m'
  NC='\033[0m'  
  echo -e "${RED}$1${NC}"
}

########### main flow  ##############
SECONDS=0
baseDir="$(pwd)"
repoDir=$1
RED='\033[0;31m'

echo "RepoDir=${repoDir}"
echo "baseDir=${baseDir}"

if [[ ! "$repoDir" =~ ^\/.* ]]; then
    printError "\n\n\t\tThe provided location[$1] is not a full path"
    printError "\n\t\tTry again.\n\n."
    exit 1
fi

gitMetaDir="${repoDir}/.git"
if [ -d "$gitMetaDir"  ]; then
    cd $repoDir
    echo "Changed dir to $(pwd)"    
else 
    printError "\n\n\t\tThe provided location[$repoDir] is not a valid git repo"
    printError "\n\t\tTry again.\n\n."
    exit 1
fi

#### initializing repoName variable ######## 
repoName="$( basename "$repoDir" )"
commitsJsonFile="${baseDir}/commits-filebeat-${repoName}.json"

#### clean up before execution (precautionary) ########
rm -f temp.log
rm -f $commitsJsonFile

####### running git log command ########
git log --remotes=origin --numstat --pretty=oneline --date=iso8601 --format="authorName:%aN%nauthorEmail:%aE%nauthorDate:%ad%nhash:%H%nsubject:%s" | grep -v -e ^[[:space:]]*$ > temp.log

############### START: processing of git log output #############################
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
      if [ "$key" == "authorName" ]; then
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
      ###### ignoring these entries #######
      echo "@Rajiv : invalid line" > /dev/null
    fi
done < temp.log

#####  special handling for the last commit entry ########
addCurrentCommit $currentCommitParams $currentCommitDiffStats $commitCount

################## END: processing of git log out ###################################

###### generating repoCommits.json file ###########
#repoName="$( basename "$repoDir" )"
#repoJsonFile="${baseDir}/array_output_gitlog-${repoName}.json"
#echo "repoName[$repoName]"
#echo "repoFile[$repoJsonFile]"

#printf "[" > $repoJsonFile
#cat "$commitsJsonFile" >> $repoJsonFile
#printf "\n]\n" >> $repoJsonFile

#######  displaying result info  ##########
#echo "Generated Json file : $repoJsonFile"

##### Removing temp.log file  #######
rm -f temp.log
#rm -f $commitsJsonFile

####### PRINTING  EXECUTION TIME ########
ELAPSED="$(($SECONDS / 3600))hrs $((($SECONDS / 60) % 60))min $(($SECONDS % 60))sec"
printError "\n\n\n\t\tExecution Time [$ELAPSED] \n\n\n"

exit 0

