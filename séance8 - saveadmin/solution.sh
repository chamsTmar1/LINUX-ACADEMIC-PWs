echo "Sauvegarde et Restauration"

while true
do

echo
echo "1- Lister les fichiers les plus volumineux"
echo "2- Save/Restore avec tar"
echo "3- Save/Restore avec dd"
echo "4- Save/Restore avec cpio"
echo "5- Save/Restore avec dump/restore"
echo "9- Quitter"

echo
read -p "Donner votre choix: " choice

case $choice in
1)	echo
	read -p "Donner un dossier (.): " dir

	if [[ -z "$dir" ]]
	then
		dir=.
	fi
	
	find "$dir" -type f -exec wc -c {} \; 2> /dev/null \
	| sort -r -n \
	| head -5
	;;
2)	echo
	echo "1- Save"
	echo "2- Restore"

	echo
	read -p "Donner votre choix (1): " choice

	if [[ -z "$choice" ]]
	then
		choice=1
	fi

	case $choice in
	1)	echo
		read -p "Le dossier a sauvegarder: " input
		read -p "Le chemin de sauvegarde: " output

		cd "$input"
		input=$(pwd)
		
		cd - > /dev/null

		tar -cvf "$output" "$input"
		;;
	2)	echo
		read -p "Le chemin de sauvegarde: " input

		if [[ ! "$input" = /* ]]
		then
			input="$(pwd)/$input"
		fi

		cd /

		tar -xvf "$input"

		cd - > /dev/null
		;;
	esac
	;;
3)	echo
	echo "1- Save"
	echo "2- Restore"

	echo
	read -p "Donner votre choix (1): " choice

	if [[ -z "$choice" ]]
	then
		choice=1
	fi

	case $choice in
	1)	echo
		read -p "Le dossier a sauvegarder: " input
		read -p "Le chemin de sauvegarde: " output

		cd "$input"
		input=$(pwd)
		
		cd - > /dev/null

		find "$input" -type d -exec mkdir -p "$output{}" \;

		find "$input" -type f -exec dd if="{}" of="$output{}" \;
		;;
	2)	echo
		read -p "Le chemin de sauvegarde: " input

		cd "$input"

		find . -type d -exec mkdir -p "/{}" \;

		find . -type f -exec dd if="{}" of="/{}" \;

		cd - > /dev/null
		;;
	esac
	;;
4)	echo
	echo "1- Save"
	echo "2- Restore"

	echo
	read -p "Donner votre choix (1): " choice

	if [[ -z "$choice" ]]
	then
		choice=1
	fi

	case $choice in
	1)	echo
		read -p "Le dossier a sauvegarder: " input
		read -p "Le chemin de sauvegarde: "  output

		cd "$input"
		input=$(pwd)
		
		cd - > /dev/null

		find "$input" | cpio -o > "$output"
		;;
	2)	echo
		read -p "Le chemin de sauvegarde: " input

		if [[ ! "$input" = /* ]]
		then
			input="$(pwd)/$input"
		fi

		cd /

		cpio -iu < "$input"

		cd - > /dev/null
		;;
	esac
	;;
5)	echo
	echo "1- Save"
	echo "2- Restore"

	echo
	read -p "Donner votre choix (1): " choice

	if [[ -z "$choice" ]]
	then
		choice=1
	fi

	case $choice in
	1)	echo
		read -p "Le dossier a sauvegarder: " input
		read -p "Le chemin de sauvegarde: " output

		sudo dump -0f "$output" "$input"
		;;
	2)	echo
		read -p "Le chemin de sauvegarde: " input

		if [[ ! "$input" = /* ]]
		then
			input="$(pwd)/$input"
		fi

		cd /

		sudo restore -rf "$input"

		cd - > /dev/null
		;;
	esac
	;;
9)	exit
	;;
esac

done

