#!/bin/bash

set -x

##1) Captures all projects from a Gitlab instance with Token and permission to read the repository in the API.
##2) Delete major project with old pipelines

## Generate files:
#
#  A)project_pipelines_cleanup.csv (.project_id,.id,.web_url,.status,.updated_at)
#

echo "#### Step:  $0"

. $PWD/000_settings.sh

if ! [ -f project_pipelines_list.txt ]; then
   echo "#######################################"
   echo "##                                   ##"
   echo "## Pipelines not found for cleaning  ##"
   echo "##                                   ##"
   echo "#######################################"
   exit
fi

if [ -f project_pipelines_cleanup.csv ]; then
   mv project_pipelines_cleanup.csv project_pipelines_cleanup.csv.old 
fi

file="project_pipelines_list.txt"

projects=1

while read -r line; do

   PROJECT_ID=`echo $line | cut -d "," -f1`
   PIPELINE_ID=`echo $line | cut -d "," -f2`
   if ! [ -z "$PROJECT_ID" ]; then
      curl --header "PRIVATE-TOKEN: $GIT_TOKEN" --request DELETE "$GIT_API/projects/$PROJECT_ID/pipelines/$PIPELINE_ID"
      echo $line >> project_pipelines_cleanup.csv;
   fi
  
   (( projects++ )) || true

done <$file

sed -i '1 i .project_id,.id,.web_url,.status,.updated_at' project_pipelines_cleanup.csv

rm -rf project_pipelines_cleanup.txt
