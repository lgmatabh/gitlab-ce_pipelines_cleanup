#!/bin/bash
#

. $PWD/000_settings.sh

exec >All_logfile.log 2>&1

echo "#### 001_gitlab_projects_statistics.sh"

bash 001_gitlab_projects_statistics.sh

echo "#### 002_gitlab_projects_pipelines_list.sh"

bash 002_gitlab_projects_pipelines_list.sh

echo "#### 003_gitlab_projects_pipelines_cleanup.sh"

bash 003_gitlab_projects_pipelines_cleanup.sh

