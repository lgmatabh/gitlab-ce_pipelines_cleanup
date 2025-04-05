# About

This tool was developed to solve a problem with the growth of the use of Gitlab-ce (Self-Managed) in the CI/CD process.

Gitlab version 17.9 allows for the cleaning of old pipelines: https://about.gitlab.com/releases/2025/02/20/gitlab-17-9-released/#automatic-cicd-pipeline-cleanup

However, when the software process does not follow the standard of sprints and consolidated versions and the commit occurs in a simple commit of a source, the pipeline artifacts accumulate.

This tool use the API/v4 and has been used ans tested several times and works with basic and simple parameterization.

In the **000_settings.sh** file, simply enter the parameters below:

1) Number of largests projects selected for cleaning

export Number_Projects=**1000**

2) Age of creation of pipelines to preserve, in case 14 days (newest than 14 days). **if only one exists for the job, it will be preserved.**

export UPDATED_BEFORE=$(date -d "$date **-14 days**" +"%Y-%m-%dT00:00:00")

3) URL of Gitlab

export GIT_API=https://**gitlab-your.domain/api/v4**

4) Gitlab token, with admin permission

export GIT_TOKEN=**glpat-xxxxxxxxxxxxxxx**
 

# Use at your own risk!!!!


# **Execution: After the configuration itens 1 a 4 above.** 


## Only execute: bash pipelines_cleanup.sh

        000_settings.sh - Only parameter settings.

Steps, below, will be executing in pipelines_cleanup.sh. You may want to execute sequentially, one by one, without executing the pipelines_cleanup.sh.


        001_gitlab_projects_statistics.sh - List the statistic for all projects, generating file .csv.

        002_gitlab_projects_pipelines_list.sh - List all pipelines of projects greater then UPDATED_BEFORE, 
                                                generating file .csv result.

        003_gitlab_projects_pipelines_cleanup.sh - Delete all pipelines selected previous for greater pipeline projects, 
                                                generating file .csv result. 

If you want to reduce the log volume in terminal, run the disable_log_file.sh or enable_log_file.sh script to activate it.

If activated, all the procedures will be recorded in the file: All_logfile.log.

