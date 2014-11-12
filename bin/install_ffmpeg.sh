#!/bin/sh

# If the download doesn't work, the release link may have changed.
# Check http://johnvansickle.com/ffmpeg/, copy the address of the
# latest release, and replace in the shell script.

# CHANGE THIS TO THE APPROPRIATE FILENAME
FNAME=ffmpeg-2.4.3-32bit-static.tar.xz

echo Downloading ffmpeg...
mkdir /home/root/bin
wget -P /home/root/bin http://johnvansickle.com/ffmpeg/releases/$FNAME

echo Unpacking .tar.xz file...
tar -xf /home/root/bin/$FNAME -C /home/root/bin

echo Cleaning up...
rm /home/root/bin/$FNAME
