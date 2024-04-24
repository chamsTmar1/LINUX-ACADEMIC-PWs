echo "Application"

while true
do

echo
echo "1- Lister les fichiers suid"
echo "2- Lister les fichiers guid"
echo "3- Lister les repertoires sticky bit"
echo "4- Lancer un sniffer (tcpdump)"
echo "5- Gerer un firewall (iptables)"
echo "6- Check suid (bit ss integrity control for user)"
echo "7- Check guid (bit ss integrity control for group)"
echo "8- Check sticky bit (bit ss integrity control for others)"
echo "9- Quitter"

read -p "Donner votre choix: " choice

case $choice in
1)	find / -perm -4000 2> /dev/null
	;;
2)	find / -perm -2000 2> /dev/null
	;;
3)	find / -perm -1000 2> /dev/null
	;;
4)	interfaces=$(sudo tcpdump -D)

	echo
	echo "Interface"
	echo "$interfaces"

	interfaces=$(echo "$interfaces" \
			| sed 's/^.*\.//' \
			| sed 's/ .*//' \
			| paste -sd'|')

	echo
	read -p "Donner l'interface: " interface

	if [[ ! "$interface" =~ "$interfaces" ]]
	then
		echo "interface invalide"
		continue
	fi

	sudo tcpdump -i $interface
	;;
5)	# Vérifier les droits d'administration
	if [[ $EUID -ne 0 ]]; then
    		echo "Ce script doit être exécuté en tant qu'administrateur (root)." 
    	exit 1
	fi

	# Afficher le menu
	echo "=== Gestion du Firewall (iptables) ==="
	echo "51. Autoriser le trafic sur un port"
	echo "52. Bloquer le trafic sur un port"
	echo "53. Autoriser toutes les connexions sortantes"
	echo "54. Bloquer toutes les connexions sortantes"
	echo "55. Afficher les règles iptables actuelles"
	echo "56. Quitter"

	# Lire le choix de l'utilisateur
	read -p "Entrez le numéro de l'option souhaitée : " choice

	# Utiliser la structure conditionnelle case pour traiter le choix de l'utilisateur
	case $choice in
    		1)
       		 	# Autoriser le trafic sur un port
        		read -p "Entrez le numéro du port à autoriser : " port
        		iptables -A INPUT -p tcp --dport $port -j ACCEPT
        		echo "Le trafic sur le port $port est autorisé."
        		;;
    		2)
        		# Bloquer le trafic sur un port
        		read -p "Entrez le numéro du port à bloquer : " port
        		iptables -A INPUT -p tcp --dport $port -j DROP
        		echo "Le trafic sur le port $port est bloqué."
        		;;
    		3)
        		# Autoriser toutes les connexions sortantes
        		iptables -P OUTPUT ACCEPT
        		echo "Toutes les connexions sortantes sont autorisées."
        		;;
    		4)
        		# Bloquer toutes les connexions sortantes
        		iptables -P OUTPUT DROP
        		echo "Toutes les connexions sortantes sont bloquées."
        		;;
    		5)
        		# Afficher les règles iptables actuelles
        		echo "Règles iptables actuelles :"
        		iptables -L
        		;;
    		6)
        		exit 0
        		;;
    		*)
        		# Gérer les choix non valides
        		echo "Option non valide. Veuillez choisir un numéro entre 1 et 6."
        		;;
	esac

	# Enregistrement des règles iptables
	service iptables save
	echo "Les règles iptables ont été enregistrées."

	# Redémarrer le service iptables
	service iptables restart
	echo "Le service iptables a été redémarré."
	;;
6)	# Utilisation de la commande find pour rechercher les fichiers avec le bit SUID
	suid_files=$(find / -type f -perm /4000 2>/dev/null)

	# Vérifier si des fichiers SUID ont été trouvés
	if [ -n "$suid_files" ]; then
    		echo -e "\nFichiers avec le bit SUID trouvés :"
    		echo "$suid_files"
	else
   		echo "Aucun fichier avec le bit SUID trouvé."
	fi
	;;
7)	# Utilisation de la commande find pour rechercher les fichiers avec le bit GUID
	guid_files=$(find / -type f -perm /2000 2>/dev/null)

	# Vérifier si des fichiers GUID ont été trouvés
	if [ -n "$guid_files" ]; then
    		echo -e "\nFichiers avec le bit GUID trouvés :"
    		echo "$guid_files"
	else
   		echo "Aucun fichier avec le bit GUID trouvé."
	fi
	;;
8)	# Utilisation de la commande find pour rechercher les fichiers avec le bit sticky
	sticky_files=$(find / -type f -perm -o+t 2>/dev/null)

	# Vérifier si des fichiers sticky ont été trouvés
	if [ -n "$sticky_files" ]; then
    		echo -e "\nFichiers avec le bit sticky trouvés :"
    		echo "$sticky_files"
	else
   		echo "Aucun fichier avec le bit sticky trouvé."
	fi
	;;
9)	exit
	;;
esac

done

