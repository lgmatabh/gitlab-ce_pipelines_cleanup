#!/bin/sh

set -x

##1) Captures all projects from a Gitlab instance with Token and permission to read the repository in the API.
##2) list  major project with old pipelines

## Generate files:
##
##  A)project_pipelines_list.csv (.project_id,.id,.web_url,.status,.updated_at)
##  B)project_pipelines_list.txt (.project_id,.id,.web_url,.status,.updated_at)


echo "#### Step:  $0"

. $PWD/000_settings.sh

if [ -f project_pipelines_list.csv ]; then
   mv project_pipelines_list.csv project_pipelines_list.csv.old 
fi
if [ -f project_without_pipelines_info.txt ]; then
   mv project_without_pipelines_info.txt project_without_pipelines_info.txt.old 
fi

PER_PAGE=1

file="1000_largest_projects.txt"

projects=1

while read -r line; do

    project_id=`echo $line | cut -d "," -f1`
    artifacts_size=`echo $line | cut -d "," -f3`

    if [ "$artifacts_size" -ne 0 ]; then


	#get total count of pipelines for projects

        total=`curl --head --header -s "$GIT_API/projects/$project_id/pipelines?private_token=$GIT_TOKEN&per_page=1&page=1&sort=asc&updated_before=$UPDATED_BEFORE"| grep -i "X-Total-Pages"|cut -d" " -f2`
        total=`echo $total|grep -o '[0-9]\+'`

        echo  $project_id " total pipelines " $total

        # first pipeline project in page
    
        page=1

        while [[ $page -lt $total  &&  $total -gt 1 ]];
           do
              # "Pipelines with more 14 days"
              line=`curl -s --header "PRIVATE-TOKEN: $GIT_TOKEN" "$GIT_API/projects/$project_id/pipelines?&per_page=$PER_PAGE&page=$page&sort=asc&updated_before=$UPDATED_BEFORE" |  jq -r '.[] | "\(.project_id),\(.id),\(.web_url),\(.status),\(.updated_at)"'`
	      if ! [ -z $line ]; then
                 echo $line >> project_pipelines_list.csv;
	      else
		   echo " without info  " $project_id " " $line >> project_without_pipelines_info.txt
	      fi
              page=$((page+1))
           done
    fi
    ((projects++)) || true
done <$file

if [ -f project_pipelines_list.csv ]; then
        cp project_pipelines_list.csv project_pipelines_list.txt
	sed -i '1 i .project_id,.id,.web_url,.status,.updated_at' project_pipelines_list.csv
fi

rm -rf 1000_largest_projects.txt
