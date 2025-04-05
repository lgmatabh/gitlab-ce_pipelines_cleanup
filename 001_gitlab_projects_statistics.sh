#!/bin/bash

set -x

##1) Captures all projects from a Gitlab instance with Token and permission to read the repository in the API.
##2) Generates CSV file, with ID, Name of project, and Storage Statistics values

## Generate files:
#
#  A)project_statistics.csv (Id, Name, Commit_count, Storage_size, Repository_size, Wiki_size, Lfs_objects_size, Job_artifacts_size, Pipeline_artifacts_size, Packages_size, Snippets_size, Uploads_size)
#  B)1000_largest_projects.csv (Id, Name, Pipeline_artifacts_size)
#  C)project_statistics.txt - All attributs of projects 
#

echo "#### Step:  $0"

. $PWD/000_settings.sh

if [ -f project_id.txt ];then
   mv project_id.txt project_id.txt.old 
fi
if [ -f project_statistics.txt ]; then
   mv project_statistics.txt project_statistics.txt.old
fi
if [ -f project_statistics.csv ]; then
   mv project_statistics.csv project_statistics.csv.old
fi
if [ -f 1000_largest_projects.csv ]; then
   mv 1000_largest_projects.csv 1000_largest_projects.csv.old
fi

#get total count of projects

total=`curl -s --head --header -s "$GIT_API/projects?private_token=$GIT_TOKEN&per_page=1&page=1"|grep -i "X-Total-Pages"|cut -d" " -f2 2>&1`
total=`echo $total|grep -o '[0-9]\+'`

echo  "Projects total: " $total

page="1" #------ first project in page

while [ $page -le $total ]
do

    #get id of project
    
    idProject=`curl -s "$GIT_API/projects?private_token=$GIT_TOKEN&per_page=1&page=$page" | jq -r ".[] | .id"`

    echo $idProject >> project_id.txt
     
    #get data of project
    
    `curl --header "Private-Token: $GIT_TOKEN" "$GIT_API/projects/$idProject?statistics=true" >> project_statistics.txt`
    echo  " " >> project_statistics.txt

    page=$((page+1))
done

#generate CSV file
	cat project_statistics.txt | jq -r '[.id, .name, .statistics.commit_count, .statistics.storage_size, .statistics.repository_size, .statistics.wiki_size, .statistics.lfs_objects_size, .statistics.job_artifacts_size, .statistics.pipeline_artifacts_size, .statistics.packages_size, .statistics.snippets_size, .statistics.uploads_size, .archived ] | @csv' >> project_statistics.csv 

file="project_statistics.csv"

while read -r line; do
    archived=`echo $line| cut -d "," -f13`
    if [ $archived != "true" ]; then
       echo $line | `cut -d "," -f1,2,8 >> largest_projects.txt`
    fi
done <$file

sort -r -n  -t',' -k3 largest_projects.txt > largest_projects_sort.txt

# First 1000 projects
head -$Number_Projects  largest_projects_sort.txt >> 1000_largest_projects.csv
head -$Number_Projects  largest_projects_sort.txt > 1000_largest_projects.txt

#header 1000_largest_projects.csv 
sed -i '1 i Id, Name, Pipeline_artifacts_size'  1000_largest_projects.csv 

#header project_statistics.csv
sed -i '1 i Id, Name, Commit_count, Storage_size, Repository_size, Wiki_size, Lfs_objects_size, Job_artifacts_size, Pipeline_artifacts_size, Packages_size, Snippets_size, Uploads_size, Archived'  project_statistics.csv

rm -rf largest_projects_sort.txt
