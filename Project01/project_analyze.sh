#!/bin/bash

cd ..
echo "Please choose your option: 1)TODO 2)FileTypeCount 3)DeletetmpFiles"
read var
case $var in
	TODO)

	    (grep -r "#TODO" --exclude="todo.log" --exclude="project_analyze.sh" .)> todo.log
	    echo "Command TODO Executed."
	    ;;
	FileTypeCount)
	    var1=$(find . -iname "*.html" | wc -l)
	    var2=$(find . -iname "*.js" | wc -l)
	    var3=$(find . -iname "*.css" | wc -l)
	    var4=$(find . -iname "*.py" | wc -l)
	    var5=$(find . -iname "*.hs" | wc -l)
	    var6=$(find . -iname "*.sh" | wc -l) 
	    echo "HTML: $var1, Javascript: $var2, CSS: $var3, Python: $var4, Haskell: $var5, Bash Script: $var6"
	    ;;
	DeletetmpFiles)
	    tfile=$(git ls-files *.tmp --exclude-standard --others)
	    rm tfile
	    echo "Command DtmpF Executed."
	    ;;
esac
