#!/bin/bash

cd ..
echo "Please choose your option: 1)TODO 2)FileTypeCount 3)DeletetmpFiles 4)CompileErrorLog 5)DBH"
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
	    rm -r $tfile
	    echo "Command DtmpF Executed."
	    ;;
	CompileErrorLog)
	    touch compile_fail.log
	    for i in $(find -name "*.hs" -type f) ;
	    do
	    ghc $i 2>> ~/CS1XA3/compile_fail.log
	    done
	    for j in $(find -name "*.py" -type f) ;
	    do
	    python $j 2>> ~/CS1XA3/compile_fail.log
	    done
	    echo "Command CEL Executed."
	    ;;
	DBH)
	    echo -e "Okay you choose to execute this DBH feature! Actually DBH is the abbreviation of \e[1mDetroit: Become Human \e[0m, a PS4 game. Do you want to know more about it? (please type Yes/No)"
	    while read answer;
	    do
	    if [ ${answer} = "Yes" ] || [ ${answer} = "yes" ]
		then
	    		echo "Premise:"
			echo "Set in Detroit during the year 2038, the city has been revitalized by the invention and introduction of androids into everyday life. But when androids start behaving as if they are alive, events begin to spin out of control."
			echo "Please choose a character: 1) Connor 2)Kara 3)Markus"
			while read choice;
			do
			if [ ${choice} = "Connor" ]
			then
				echo "Connor is an RK800 android and one of the three protagonists in Detroit: Become Human. Built as an advanced prototype, he is designed to assist human law enforcement; specifically in investigating cases involving deviant androids. Sent to the Detroit City Police Department, Connor has been assigned to work with Lt. Hank Anderson. Throughout the course of their investigation, Connor may make discoveries about cases, himself, and become a deciding agent in tipping the coming events."
				echo "Do you want to know about other characters? If yes, please enter his or her name."
			elif [ ${choice} = "Kara" ]
			then
				echo "Kara is an AX400 android and one of the three protagonists in Detroit: Become Human. She is a common housemaid android serving in the home of her owner Todd Williams and caring for his daughter Alice. Kara's connection to her young charge may trigger an upheaval that breaks Kara from her repetitive existence and starts her on a journey out into the world, at a time when androids may rise up and confront their creators."
				echo "Do you want to know about other characters? If yes, please enter his or her name."
			elif [ ${choice} = "Markus" ]
			then
				echo "Markus is an RK200 android and one of the three protagonists of Detroit: Become Human. He is a domestic android owned by famous Detroit painter Carl Manfred. Events catapult him out of his familiar life and lead him on to freedom and rebellion. During the game, he may become the leader of the deviants and may direct them in either a violent or peaceful revolt against human oppression and thus decide the future of his species."
				echo "Do you want to know about other characters? If yes, please enter his or her name."
			else
				echo "Please enter the correct name."
			fi
			done
		elif [ ${answer} = "No" ] || [ ${answer} = "no" ]
		then
			echo "DBH feature ended."
			break
		else
			echo "Please enter Yes or No."
            fi
	    done
	    ;;
esac

