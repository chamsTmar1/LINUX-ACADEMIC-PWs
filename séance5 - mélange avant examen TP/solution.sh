echo "Administration des systemes UNIX"

while true
do

echo
echo "1- Gestion des modules"
echo "2- Arret & Demarrage du systeme"
echo "3- Gestion des processus"
echo "999- Quitter"

echo
read -p "Donner votre choix: " choice

case $choice in
1)	echo "Gestion des modules"

	while true
	do

	echo
	echo "11- Lister les modules actifs"
	echo "12- Desactiver un module"
	echo "13- Activer un module"
	echo "14- Lister les modules supprimes"
	echo "19- Revenir au menu precedent"
	echo "999- Quitter"

	echo
	read -p "Tapez votre choix: " choice

	case $choice in
	11)	lsmod \
		| cut -f 1 -d ' ' \
		| tail -n +2 > modules.txt
		<modules.txt xargs -d $'\n' \
			sh -c 'for arg do modinfo "$arg" \
			| (grep description: || printf "\n") \
			| sed "s/^[[:alnum:]]*:[[:space:]]*//";done' _ > descriptions.txt
		echo "" >> modules.txt
		sed -i "1s/^/Module\n/" modules.txt	
		echo "" >> descriptions.txt
		sed -i "1s/^/Description\n/" descriptions.txt
		pr -m -t modules.txt descriptions.txt \
		| head -n -1
		rm modules.txt descriptions.txt
		;;
	12)	echo
		read -p "Donnez le module a desactiver: " mod
		sudo modprobe -r $mod
		;;
	13)	echo
		read -p "Donnez le module a activer: " mod
		sudo modprobe $mod
		;;
	14)	lsmod \
		| cut -f 1 -d ' ' \
		| tail -n +2 > modules.txt
		find /lib/modules/$(uname -r) -type f -name '*.ko*' \
		| sed -n -e 's/^.*\///p' \
		| sed -n -e 's/\.ko.*//p' > all_modules.txt
		grep -v -x -f modules.txt all_modules.txt
		rm modules.txt all_modules.txt
		;;
	19)	break
		;;
	999)	exit
		;;
	esac

	done
	;;
2)	echo "Arret & Demarrage du systeme"

	while true
	do

	echo
	echo "21- Arret du systeme"
	echo "22- Afficher le niveau d'execution actuel"
	echo "23- Runlevels"
	echo "29- Revenir au menu precedent"
	echo "999- Quitter"

	echo
	read -p "Tapez votre choix: " choice

	case $choice in
	21)	sudo init 0
		;;
	22)	r=$(who -r)
		echo "Le niveau d'execution actuel est $r"
		;;
	23)	while true
		do
		
		echo
		echo "231- Afficher le niveau d'execution par default"
		echo "232- Afficher les applications qui entraine l'arret du systeme"
		echo "233- Afficher toutes les applications arret & demarrage"
		echo "239- Revenir au menu precedent"
		echo "999- Quitter"
	
		echo	
		read -p "Tapez votre choix: " choice
	
		case $choice in
		231)	grep "id:.*:initdefault:" /etc/inittab
			;;
		232)	ls /etc/rc0.d \
			| nl
			;;
		233)	ls -l /etc/init.d/* \
			| sed  -n -e 's/^.*\///p'
			;;
		239)	break
			;;
		999)	exit
			;;	
		esac
		
		done
		;;
	29)	break
		;;
	999)	exit
		;;
	esac

	done
	;;
3)	echo "Gestion des processus"

	while true
	do

	echo
	echo "31- Lister tous les processus"
	echo "32- Lister les processus par utilisateur tries par PID (PID, Nom Process, PPID)"
	echo "33- Afficher le PID du processus de login de chacun des utilisateurs connectes"
	echo "34- Deconnecter un utilisateur"
	echo "35- Lister les processus fils d'un processus donne (PID, Nom)"
	echo "36- Lister les processus parents d'un processus donne (PID, Nom)"
	echo "37- Gerer un processus"
	echo "39- Revenir au menu precedent"
	echo "999- Quitter"
	
	echo
	read -p "Donner votre choix: " choice

	case $choice in
	31)	ps -ef | awk '{printf("%s\t%s\n", $2, $8);}'
		;;
	32)	user=$(id -u)
		ps -ef \
		| grep -w "^$user" \
		| awk '{printf("%s\t%s\t%s\n", $2, $8, $3);}' \
		| sort -n
		;;
	33)	ps -o uid,pid | head -1
		users=$(ps -e -o uid= | sort -n | uniq)
		for user in $users
		do
			ps -u $user -o uid,pid --no-headers | head -1
		done
		;;
	34)	echo
		read -p "Donner l'utilisateur: " user
		
		if [[ -z  "$user" ]]
		then
			user=$(whoami)
		fi
		
		pkill -p -i $user
		;;
	35)	echo
		read -p "Donner le PID du processus: " pid
		
		if [[ -z  "$pid" ]]
		then
			pid=$$
		fi
		
		pidlist="$pid"

		pid=$(ps --ppid $pid -o pid= | awk '{print $1}' | paste -d, -s)
		
		while [[ ! -z "$pid" ]]
		do
		
		pidlist="$pidlist,$pid"
		pid=$(ps --ppid $pid -o pid= | awk '{print $1}' | paste -d, -s)
		
		done

		ps -p $pidlist -o pid,cmd
		;;
	36)	echo
		read -p "Donner le PID du processus: " pid
		
		if [[ -z  "$pid" ]]
		then
			pid=$$
		fi
		
		ps -p $pid -o pid,cmd
		pid=$(ps -p $pid -o ppid=)

		while [ $pid -gt 0 ]
		do

		ps -p $pid -o pid,cmd --no-headers
		pid=$(ps -p $pid -o ppid=)

		done
		;;
	37)	echo
		read -p "Donner le PID du processus: " pid
		
		echo
		echo "1- kill"
		echo "2- stop"
		echo "3- continue"
		
		echo
		read -p "Donner votre choix: " op

		case $op in
		1)	op="SIGKILL"
			;;
		2)	op="SIGSTOP"
			;;
		3)	op="SIGCONT"
			;;
		esac

		kill -s $op $pid
		;;
	39)	break
		;;
	999)	exit
		;;
	esac
	
	done
	;;
999)	exit
	;;
esac

done

