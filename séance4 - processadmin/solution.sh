while true
do

echo "1- Lister tous les processus"
echo "2- Lister les process par utilisateur tries par PID (PID, Nom Process, PPID)"
echo "3- Afficher le PID du processus de login de chacun des utilisateurs connectes"
echo "4- Deconnecter un utilisateur"
echo "5- Lister les processus fils d'un processus donne (PID, Nom)"
echo "6- Lister les processus parents d'un processus donne (PID, Nom)"
echo "7- Quitter"
echo

read -p "Donner votre choix: " choice
echo

case $choice in
1)	ps -ef | awk '{printf("%d\t%s\n", $2, $8);}'
	;;
2)	user=$(id -u)
	ps -ef \
	| grep -w "^$user" \
	| awk '{printf("%d\t%s\t%d\n", $2, $8, $3);}' \
	| sort -n
	;;
3)	ps -e | grep 'login'
	;;
4)	read -p "Donner l'utilisateur: " user
	if [[ ! -z  "$user" ]]
	then
		user=$(whoami)
	else
		:
	fi
	pkill -p -i $user
	;;
5)	pid=$$
	ps -p $pid -o pid,cmd
	pid=$(ps -p $pid -o ppid=)

	while [ $pid -gt 0 ]
	do

	ps -p $pid -o pid=,cmd=
	pid=$(ps -p $pid -o ppid=)

	done
	;;
6)	pid=$$
	ps -p $pid -o pid,cmd
	pid=$(ps -p $pid -o ppid=)

	while [ $pid -gt 0 ]
	do

	ps -p $pid -o pid,cmd --no-headers
	pid=$(ps -p $pid -o ppid=)

	done
	;;
7)	exit
	;;
esac

done

