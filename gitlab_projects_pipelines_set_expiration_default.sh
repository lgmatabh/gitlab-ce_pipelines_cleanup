#!/bin/bash
set -x
#
## Configure all projects with default pipeline lifetime
#
##1) Reads all projects from a Gitlab instance with token and admin permission to the repository in the API.
#
##2) Generates CSV file with ID data of projects

## Generate files:
#
#  A)project_statistics.pipeline_expiration_default.csv

echo "#### Step:  $0"

. $PWD/000_settings.sh

if [ -f project_statistics.pipeline_expiration_default.csv ]; then
   mv project_statistics.pipeline_expiration_default.csv project_statistics.pipeline_expiration_default.csv.old
fi

#get total count of projects

total=`curl --head --header -s "$GIT_API/projects?private_token=$GIT_TOKEN&per_page=1&page=1"|grep -i "X-Total-Pages"|cut -d" " -f2`

total=`echo $total|grep -o '[0-9]\+'`

echo " total projets" $total

page="1" #------ first project in page

while [ $page -le $total ];
do
    #get id of project
    
    idProject=`curl -s "$GIT_API/projects?private_token=$GIT_TOKEN&per_page=1&page=$page" | jq -r ".[] | .id"`
     
    #Get data of project
    
    `curl --header "Private-Token: $GIT_TOKEN" "$GIT_API/projects/$idProject?statistics=true" > project_statistics.txt`
    
     archived=`cat project_statistics.txt | jq -r '.archived'`

     if [ "$archived" != "true" ]; then
  
        #  Days in seconds -> 60×60×24×14=1209600 -> should be in seconds 
        curl --request PUT --header "PRIVATE-TOKEN: $GIT_TOKEN" --url "$GIT_API/projects/$idProject" --data "ci_delete_pipelines_in_seconds=$Days_in_seconds"
        
	cat project_statistics.txt | jq -r '[.id, .name, .ci_delete_pipelines_in_seconds] | @csv' >> project_statistics.pipeline_expiration_default.csv
     fi

    page=$((page+1))
done

rm -rf project_statistics.txt

#header
sed -i '1 i Id, Name, Pipeline_expire' project_statistics.pipeline_expiration_default.csv
