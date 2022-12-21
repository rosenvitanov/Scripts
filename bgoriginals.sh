#! /bin/bash

## This script downloads everything: from http://bulgarianoriginals70s-80s.blogspot.com
## Save description from website in a readme file

##--------------------------------------------------------------------------------------------------------
BASEDIR="./BulgarianOriginals"
LinkToPost=""
LinkToNextToDownload=""
RAWHTML=""


## This script starts here
## Draw a greeting message
clear
echo "Bulgarian originals download script"
echo "http://bulgarianoriginals70s-80s.blogspot.com"
echo "This script tries to make an archive of this website automatically"
echo "It needs an entry point and continues from that point. Download is from the oldest to the newest"
echo "------------------------------------------------------------------------------------------------"
echo ""

##-------------------------------------------------------------------------------------------------------
if [ ! -d "$BASEDIR" ]; then  
  echo "No base directory found. Making a new directory"

  mkdir $BASEDIR

fi

## Process the entry point
if [ -z $1 ]
then
	LinkToPost=$(cat ./$BASEDIR/last_saved.info)
else
	LinkToPost=$1
fi

if [ -z $LinkToPost ] 
then
	echo "No entry point. Exiting"
	exit
fi
echo "Entry point is:"
echo $LinkToPost
echo ""

echo "Real link:"
LinkToPost=$(echo $LinkToPost | egrep -o 'http:\/\/bulgarianoriginals70s-80s.blogspot.com\/\S+.html' | head -n1)
if [ -z $LinkToPost ] 
then

	echo "Not a valid entry point. Exiting"
	exit
fi
LinkToPost="$LinkToPost?m=1"
echo $LinkToPost
echo ""

echo "Next to download is:"
RAWHTML=$(wget -qO- $LinkToPost)
DownloadLink=$(echo $RAWHTML | egrep -o "http:\/\/www.mediafire.com\\S+\"" | rev | cut -c 2- | rev)
echo $DownloadLink
LinkToNextToDownload=$(echo $RAWHTML | egrep -o "<a class='blog-pager-newer-link' href='http:\/\/bulgarianoriginals70s-80s.blogspot.com\S+.html" | cut -c 40-)
echo $LinkToNextToDownload

echo "Saving the latest sucessfully downloaded album"
echo $LinkToPost > "./$BASEDIR/last_saved.info"

