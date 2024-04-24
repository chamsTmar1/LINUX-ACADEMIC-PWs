echo "Administration arret & demarrage du systeme"

while true
do

echo ""
echo "1: Arret du systeme"
echo "2: Afficher le niveau d'execution actuel"
echo "3: Runlevels"
echo "99: Quitter"

read -p "Tapez votre choix: " choice

case $choice in
1)	sudo init 0
	;;
2)	r=$(who -r)
	echo "Le niveau d'execution actuel est $r"
	;;
3)	while true
	do

	echo ""
	echo "31: Afficher le niveau d'execution par default"
	echo "32: Afficher les applications qui entraine l'arret du systeme"
	echo "33: Afficher toutes les applications arret & demarrage"
	echo "39: Revenir au menu precedent"
	echo "99: Quitter"
	
	read -p "Tapez votre choix: " choice

	case $choice in
	31)	grep "id:.*:initdefault:" /etc/inittab
		;;
	32)	ls /etc/rc0.d \
		| nl
		;;
	33)	ls -l /etc/init.d/* \
		| sed  -n -e 's/^.*\///p'
		;;
	39)	break
		;;
	99)	exit
		;;	
	esac

	done
	;;
99)	exit
	;;
esac

done

