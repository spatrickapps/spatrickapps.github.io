#!/bin/bash

script_dir=$(dirname $0)
cur=$(pwd)

cd "$script_dir"
if [ $# -eq 0 ]; then
  echo "Usage: $0 <command>" >&2
  exit 1
fi

if [ "$1" == "add" ]; then
	if [ "$#" -ne 3 ]; then
	  echo "Usage: $0 add <package> <deb file>" >&2
	  exit 1
	fi
	echo "Adding new package...";

	cp "$3" "$script_dir/debs/$2.deb"

elif [ "$1" == "update" ]; then
	echo "Updating packaging...";
else
	echo "Usage: $0 <command>" >&2
	exit 1
fi

rm Packages.bz2
rm Packages.txt

for deb in debs/*.deb
do
	echo "Processing $deb...";
  dpkg-deb -f "$deb" >> Packages.txt
  md5sum "$deb" | echo "MD5sum: $(awk '{ print $1 }')" >> Packages.txt
  wc -c "$deb" | echo "Size: $(awk '{ print $1 }')" >> Packages.txt
  echo "Filename: $deb" >> Packages.txt
  dpkg-deb -f "$deb" Package.txt | echo "Depiction: http://$(head -n 1 CNAME)/depictions/?p=$(xargs -0)" >> Packages.txt
  echo "" >> Packages.txt
done

echo "" >> Packages.txt; ## Add extra new line

bzip2 < Packages.txt > Packages.bz2
gzip -9c < Packages.txt > Packages.gz

cd "$cur"
