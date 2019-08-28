#!/bin/sh
# ideas used from https://gist.github.com/motemen/8595451
# abort the script if there is a non-zero error
set -e
# show where we are on the machine
pwd
# because the config.yml run the command with parameter:path, set it.
siteSource="$1"

if [ ! -d "$siteSource" ]
then
    echo "Usage: $0 <site source dir>"
    exit 1
fi
cd ${siteSource}
# check current foler and fiels
pwd
ls
#########
# version manage: actually, we need to use git to manage the version, and use CI automatically
#   to retrieve the version. But we want to use the Overleaf to edit Latex, so it cannot make
#   make tag. So I decide to use the hand-made or script-made separate txt file to manage
#   verion.
# There are two version file:
# 1. in tex source project under the .circleci folder `latest-version.txt`
# 2. in published project `version.txt`
#########
# Variables MUST UPDATED
G_GIT_EMAIL=x.meng@outlook.com  # update to your email address which will be used as commit author
G_GIT_NAME="Xin Meng"           # update to your name which will be used as commit author
PUBLISH_GIT_REPO=git@github.com:xmeng1/texpdf.git # update to your repo for publish web page with PDF files
PUBLISH_GIT_BRANCH=master       # the branch used in the publish repo
# MUST UPDATED END

PUBLISH_FOLDER=texpdf           # KEEP IT

CURRENT_VERSION_FILE=version.txt       # in publish repo folder KEEP IT
LATEST_VERSION_FILE=latest-version.txt # in top folder KEEP IT

PDF_NAME_PREFIX="professional_pdf_"
PDF_NAME_LATEST=${PDF_NAME_PREFIX}"latest.pdf"

TEX_BUILD_PDF_NAME=main.pdf

PDF_FILE_STORAGE_FOLDER=pdf/publish

# get the version information
latest_version=$(cat ${LATEST_VERSION_FILE}) # the version will be update to
echo "latest version:"${latest_version}

PDF_NAME_NEW_VERSION=${PDF_NAME_PREFIX}"v"${latest_version}".pdf"
PDF_BUILD="../${TEX_BUILD_PDF_NAME}"

# make a directory to put the public project
mkdir -p ${PUBLISH_FOLDER}
cd ${PUBLISH_FOLDER}
# now lets setup a new repo so we can update it with new generated PDF
git config --global user.email "${G_GIT_EMAIL}" > /dev/null 2>&1
git config --global user.name "${G_GIT_NAME}" > /dev/null 2>&1
git init
# get current publish
git remote add --fetch origin "${PUBLISH_GIT_REPO}"
git pull origin ${PUBLISH_GIT_BRANCH}

current_version=$(cat ${CURRENT_VERSION_FILE}) # the previous version
echo "current version:"$current_version

echo ${current_version}
echo ${latest_version}
# if latest version is diff with previous version, we publish it
if [ "$latest_version" != "$current_version" ] ; then
    echo "Start new version publish and update"
    ls -al
    # update the current version
    echo ${latest_version} > version.txt
    # make dir of PDF_FILE_STORAGE_FOLDER
    mkdir -p ${PDF_FILE_STORAGE_FOLDER}
    # remove the current latest pdf
    rm -f ${PDF_FILE_STORAGE_FOLDER}/${PDF_NAME_LATEST}
    # update the latest and add new version pdf
    cp ${PDF_BUILD} ${PDF_FILE_STORAGE_FOLDER}/${PDF_NAME_LATEST}
    cp ${PDF_BUILD} ${PDF_FILE_STORAGE_FOLDER}/${PDF_NAME_NEW_VERSION}
    # push
    git add -A
    git commit -m "update to version: "${latest_version}
    git push --quiet origin master
    # out of the publish folder
    cd ..
    rm -rf ${PUBLISH_FOLDER}
    echo "New version publish and update version finish"
fi

# # switch into the the gh-pages branch
# if git rev-parse --verify origin/gh-pages > /dev/null 2>&1
# then
#     git checkout gh-pages
#     # delete any old site as we are going to replace it
#     # Note: this explodes if there aren't any, so moving it here for now
#     git rm -rf .
# else
#     git checkout --orphan gh-pages
# fi