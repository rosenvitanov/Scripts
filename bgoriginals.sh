#! /bin/bash

## This script downloads everything: from http://bulgarianoriginals70s-80s.blogspot.com
## Save description from website in a readme file
## Software needed:
## sudo apt-get install -y wget grep 
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

## Process the entry point. If no entry point (link) as an argument - try to load it from a save file.
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

## Get the page itself as HTML to parse the links
RAWHTML=$(wget -qO- $LinkToPost)
if [ -z "$RAWHTML" ]
then
	echo "Unable to retrieve page. Exiting"
	exit
fi

## Get the Mediafire download link
echo "Mediafire link is:"
MediafireLink=$(echo $RAWHTML | egrep -o "http:\/\/www.mediafire.com\\S+\"" | rev | cut -c 2- | rev)
echo $MediafireLink
if [ -z "$MediafireLink" ] 
then
	echo "Unable to retrieve mediafire link. Exiting"
	exit
fi
echo ""

echo "Next to download is:"
LinkToNextToDownload=$(echo $RAWHTML | egrep -o "<a class='blog-pager-newer-link' href='http:\/\/bulgarianoriginals70s-80s.blogspot.com\S+.html" | cut -c 40-)
echo $LinkToNextToDownload
if [ -z $LinkToNextToDownload ] 
then
	echo "Unable to next page. Exiting"
	exit
fi
echo ""

## Dump human readable webpage to file
lynx -dump -justify -hiddenlinks=ignore -notitle -nomargins -trim_input_fields  $LinkToPost > ./readme
#Remove all empty lines (including lines with whitespaces only
sed -i '/^$/d' ./readme
#Remove trailing and heading whitespaces
sed -i 's/^[ \t]*//;s/[ \t]*$//' ./readme
#Remove everything after "References""
sed -i -E '/^References$/,$d' ./readme
#remove all lines starting with []
sed -i '/^\[/d' ./readme
sed -i '/^#/d' ./readme

echo "Saving the latest sucessfully downloaded album"
echo $LinkToPost > "./$BASEDIR/last_saved.info"

