echo "Administration des reseaux"

while true
do

echo
echo "1- Afficher les interfaces"
echo "2- Afficher les interfaces avec adresse mac"
echo "3- Afficher les interfaces avec adresses ip"
echo "4- Changer l'adresse ip d'une interface"
echo "5- Afficher les ports et les services"
echo "6- Desactiver un port"
echo "7- Activer un port"
echo "8- Troubleshooting/Tester une adressee ip (ping)"
echo "9- Trouver l'adresse ip d'une url (nslookup)"
echo "10- Transferer un fichier (ftp: file transfer protocol)"
echo "11- Se connecter sur une machine distante (telnet)"
echo "99- Quitter"

echo
read -p "Donner votre choix: " choice

case $choice in
1)	ifconfig -a \
	| grep "^[[:alpha:]]" \
	| awk '{print $1}'
	;;
2)	interfaces=$(ifconfig -a \
		| grep "^[[:alpha:]]" \
		| awk '{print $1}')

	for interface in $interfaces
	do

	addr=$(ifconfig $interface \
		| grep "HWaddr" \
		| sed 's/^.*HWaddr //')

	if [[ ! -z "$addr" ]]
	then
		echo -e "$interface\t$addr"
	fi

	done
	;;
3)	interfaces=$(ifconfig -a \
		| grep "^[[:alpha:]]" \
		| awk '{print $1}')

	for interface in $interfaces
	do

	addr=$(ifconfig $interface \
		| grep "net addr:" \
		| sed 's/^[ \t]*inet addr://' \
		| sed 's/ .*//')

	if [[ ! -z "$addr" ]]
	then
		echo -e "$interface\t$addr"
	fi

	done
	;;
4)	echo
	echo "Interface"
	ifconfig -a \
	| grep "^[[:alpha:]]" \
	| awk '{print $1}'
	
	echo
	read -p "Choisir une interface: " interface

	interfaces=$(ifconfig -a \
        	| grep "^[[:alpha:]]" \
        	| awk '{print $1}' \
		| paste -sd'|')
	
	if [[ ! "$interface" =~ "$interfaces" ]]
	then
		echo "interface invalide"
		continue
	fi

	echo
	read -p "Donner l'adresse ip: " addr

	pattern="(25[0-5]|2[0-4][0-9]|1[0-9][0-9]|[1-9][0-9]|[0-9])"
	addr_pattern="^(${pattern}\.){3}${pattern}(\/(3[0-2]|[12][0-9]|[0-9]))?$" 

	if [[ ! "$addr" =~ $addr_pattern ]]
	then
		echo "adresse ip invalide"
		continue
	fi

	if [[ $addr =~ "\/" ]]
	then
		sudo ifconfig $interface $addr
		continue
	fi

	echo
	read -p "Donner le masque de sous-reseau: " mask

	mask_pattern="^(${pattern}\.){3}${pattern}$" 
	
	if [[ ! "$mask" =~ $mask_pattern ]]
	then
		echo "masque sous-reseau invalide"
		continue
	fi
	
	m=0

	for i in $(echo $mask | sed 's/\./ /g')
	do
		m=$(( (m << 8) + i ))
	done

	b=$(echo "obase=2;$m" | bc)

	if [[ $m -ne 0 ]] && ([[ ${#b} -ne 32 ]] || [[ ! "$b" =~ ^1*0*$ ]])
	then
		echo "masque sous-reseau invalide"
		continue
	fi

	sudo ifconfig $interface $addr netmask $mask
	;;
5)	cat /etc/services
	;;
6)	echo
	read -p "Donner le port: " port

	if [[ -z $port ]]
	then
		echo "Le port doit etre specifie"
		continue
	fi

	sudo sed -i "\,^[^#]*[[:space:]]${port}\(/\|[[:space:]]\|\$\), s,.,#&," /etc/services
	;;
7)	echo
	read -p "Donner le port: " port

	if [[ -z $port ]]
	then
		echo "Le port doit etre specifie"
		continue
	fi

	sudo sed -i "\,^\([[:space:]]*#\)*[^#]*[[:space:]]${port}\(/\|[[:space:]]\|\$\), s,\([[:space:]]*#\)*,," /etc/services
	;;
8)	echo
	read -p "Donner l'adresse ip: " addr

	pattern="(25[0-5]|2[0-4][0-9]|1[0-9][0-9]|[1-9][0-9]|[0-9])"
	addr_pattern="^(${pattern}\.){3}${pattern}$" 

	if [[ ! "$addr" =~ $addr_pattern ]]
	then
		echo "adresse ip invalide"
		continue
	fi

	ping $addr
	;;
9)	echo
	read -p "Donner l'url: " url

	nslookup $url
	;;
10)	echo
	read -p "Donner l'url du serveur ftp: " url
	read -p "Donner le port (21): " port

	if [[ -z "$port" ]]
	then
		port=21
	fi

	read -p "Donner le nom d'utilisateur ($USER): " username

	if [[ -z "$username" ]]
	then
		username=$USER
	fi
	
	read -s -p "Donner le mot de passe: " password
	
	echo
	read -p "Donner le nom du fichier locale: " local_file
	read -p "Donner le nom du fichier distant (fichier locale): " remote_file
	
	if [[ -z "$remote_file" ]]
	then
		remote_file=$local_file
	fi

	echo "open $url $port
	user $username $password
	put $local_file $remote_file" | ftp -n 
	;;
11)	echo
	read -p "Donner l'url: " url
	read -p "Donner le port (23): " port

	if [[ -z "$port" ]]
	then
		port=23
	fi

	telnet $url $port
	;;
99)	exit
	;;
esac

done

