#! /bin/bash

## This script downloads everything: from http://bulgarianoriginals70s-80s.blogspot.com
## Save description from website in a readme file
## Software needed:
## sudo apt-get install -y wget grep unrar cut lynx sed 
##--------------------------------------------------------------------------------------------------------
## TODOs:
##   1. Handle multiple archives - some albums consist of two archives. This albums are not handled yet.
##--------------------------------------------------------------------------------------------------------
BASEDIR="BulgarianOriginals"
LinkToPost=""
LinkToNextToDownload=""
RAWHTML=""

while :
do

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
	LinkToPost=$(cat ./$BASEDIR/next.info)
else
	LinkToPost=$1
fi

if [ -z $LinkToPost ] 
then
	echo "No entry point. Exiting"
	read
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
	read
	exit
fi
LinkToPost="$LinkToPost?m=1"
echo $LinkToPost
echo ""
echo $LinkToPost > "./$BASEDIR/last_saved.info"

## Get the page itself as HTML to parse the links
echo " - Retrieving post page ..."
RAWHTML=$(wget -qO- $LinkToPost)
if [ -z "$RAWHTML" ]
then
	echo "Unable to retrieve page. Exiting"
	read
	exit
fi

## Get the Mediafire download link
echo "Mediafire link is:"
MediafireLink=$(echo $RAWHTML | egrep -o "http:\/\/www.mediafire.com\\S+\"" | rev | cut -c 2- | rev)
echo $MediafireLink
if [ -z "$MediafireLink" ] 
then
	echo "Unable to retrieve mediafire link. Exiting"
	read
	exit
fi
echo ""

echo "Next to download is:"
LinkToNextToDownload=$(echo $RAWHTML | egrep -o "<a class='blog-pager-newer-link' href='http:\/\/bulgarianoriginals70s-80s.blogspot.com\S+.html" | cut -c 40-)
echo $LinkToNextToDownload
if [ -z $LinkToNextToDownload ] 
then
	echo "Unable to next page. Exiting"
	read
	exit
fi
echo ""


## Dump human readable webpage to file
echo " - Retrieving readme ... "
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

#Extract the date of the publicated album into array
echo "Currently processing date"
ALBUMDATE=($(sed -n 1p ./readme))
mkdir -p ./$BASEDIR/${ALBUMDATE[3]}/${ALBUMDATE[2]}
echo "./$BASEDIR/${ALBUMDATE[3]}/${ALBUMDATE[2]}"
echo ""
#Retrieve the mediafire webpage 
echo " - Retrieving mediafire page ..."
RAWHTMLMEDIAFIRE=$(wget -qO- $MediafireLink)
if [ -z "$RAWHTMLMEDIAFIRE" ]
then
	echo "Unable to retrieve Mediafire page. Exiting"
	read
	exit
fi
#Extract actual link to the file from Mediafire's servers'
LinkToRealFile=$(echo $RAWHTMLMEDIAFIRE | egrep -o "Download file\" \S+.rar" | cut -c 22-)
echo "Link to file is:"
echo $LinkToRealFile
echo ""

echo " - Retrieveing the file itself ..."
wget -O tmp.rar $LinkToRealFile

#and urar it
echo "Testing rararchive"
RARTEST=$(unrar t tmp.rar | grep "All OK")
echo "Extracting ..."
unrar x tmp.rar ./$BASEDIR/${ALBUMDATE[3]}/${ALBUMDATE[2]}


BDIRRAR=$(unrar vb tmp.rar | egrep -m 1 -o .+\/)

echo "Saving readme into:"
echo ./$BASEDIR/${ALBUMDATE[3]}/${ALBUMDATE[2]}/${BDIRRAR}
mv ./readme "./$BASEDIR/${ALBUMDATE[3]}/${ALBUMDATE[2]}/${BDIRRAR}"
echo ""
rm tmp.rar

echo "Saving the latest sucessfully downloaded album"

echo $LinkToNextToDownload > "./$BASEDIR/next.info"
if [ -z "$RARTEST" ]
then
	echo "Error extracting this archive"
	read
fi
done
