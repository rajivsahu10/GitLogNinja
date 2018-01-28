# Extracting git log informatin as JSON

This is a basic implementation using shell scripting to extract git log output in JSON format. 



Sample execution of the script: 
 shell  [rajiv@localhost gitNinja]$ ./gitlog2json.sh <full-path-of-a-local-git-repo>
 


Limitations: 
    1. It's configured to extract commit of only remote branches(commits which have been pushed to remote).
    2. Only one git repo's info can be extracted at a time.
    