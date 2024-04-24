echo "Application"

while true
do

echo ""
echo "1: Lister les modules actifs"
echo "2: Desactiver un module"
echo "3: Activer un module"
echo "4: Lister les modules supprimes"
echo "5: Quitter"

echo ""
echo "Tapez votre choix"
read choix

case $choix in
1)	lsmod \
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
2)	echo ""
	echo "Donnez le module a desactiver"
	read mod
	sudo modprobe -r $mod
	;;
3)	echo ""
	echo "Donnez le module a activer"
	read mod
	sudo modprobe $mod
	;;
4)	lsmod \
	| cut -f 1 -d ' ' \
	| tail -n +2 > modules.txt
	find /lib/modules/$(uname -r) -type f -name '*.ko*' \
	| sed -n -e 's/^.*\///p' \
	| sed -n -e 's/\.ko.*//p' > all_modules.txt
	grep -v -x -f modules.txt all_modules.txt
	rm modules.txt all_modules.txt
	;;
5)	exit
	;;
esac

done

