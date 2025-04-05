#!/bin/bash

#Number of project largest selected for pipeline cleanup

export Number_Projects=1000

#Age of creation of pipelines to preserve, in case 14 days

export UPDATED_BEFORE=$(date -d "$date -14 days" +"%Y-%m-%dT00:00:00")

#URL of Gitlab

export GIT_API=https://your_gitlab.domain/api/v4

#  GIT_TOKEN,  with admin rights

export GIT_TOKEN=glpat-xxxxxxxxxxxxxxxxx

if [ ! "$BASH_VERSION" ] ; then
	echo "Please do not use sh to run this script. ($0), use bash $0" 1>&2
    exit 1
fi

