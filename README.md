## Purpose

** This is a basic implementation using shell scripting to extract git log output in JSON format **



## Sample execution of the script: 
```
  [rajiv@localhost gitNinja]$ ./gitlog2json.sh <full-path-of-a-local-git-repo>
```
Example: 
```
[rajiv@localhost gitNinja]$ vi gitlog2json.sh 
[rajiv@localhost gitNinja]$ ./gitlog2json.sh /home/rajiv/gitNinja/sampleRepos/spring-data-keyvalue-examples/
RepoDir=/home/rajiv/gitNinja/sampleRepos/spring-data-keyvalue-examples/
baseDir=/home/rajiv/gitNinja
Changed dir to /home/rajiv/gitNinja/sampleRepos/spring-data-keyvalue-examples
repoName[spring-data-keyvalue-examples]
repoFile[/home/rajiv/gitNinja/output_gitlog-spring-data-keyvalue-examples.json]
Generated Json file : /home/rajiv/gitNinja/output_gitlog-spring-data-keyvalue-examples.json

		Execution Time [0hrs 0min 7sec] 

[rajiv@localhost gitNinja]$ 

```
## Sample output files are in the code base: 
- [output_gitlog-GitLogNinja.json](output_gitlog-GitLogNinja.json)
- [output_gitlog-movie_catalog.json](output_gitlog-movie_catalog.json)
- [output_gitlog-spring-data-keyvalue-examples.json](output_gitlog-spring-data-keyvalue-examples.json)


## Limitations: 

    - 1. It's configured to extract commit of only remote branches(commits which have been pushed to remote).
    - 2. Only one git repo's info can be extracted at a time.
    
## Pending items 
  - [ ] improve cmdline arguments parsing using getopts
  - [ ] accept more cmd line argument like destination location for output, etc
  - [ ] support output as csv
  - [ ] add scripts to push commits json objects to elastic search