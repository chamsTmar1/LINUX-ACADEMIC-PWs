echo "Premier Processus"

while true
do

echo "1- Afficher le numero du processus"
echo "2- Afficher le nom du processus"
echo "3- Afficher le parent du processus"
echo "4- Afficher les parents du processus"
echo "5- Afficher l'endroit du processus"
echo "6- Quitter"

echo "Donner votre choix:"
read choix

case $choix in
1)	echo $$
	;;
2)	echo $0
	;;
3)	echo $PPID
	;;
4)	pid=$$
	ps -p $pid -o pid
	pid=$(ps -p $pid -o ppid=)

	while [ $pid -gt 0 ]
	do

	ps -p $pid -o pid=
	pid=$(ps -p $pid -o ppid=)

	done
	;;
5)	whereis $0
	;;
6)	exit
	;;
esac

done

