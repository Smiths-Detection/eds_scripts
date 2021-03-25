#! /bin/bash


usage()
{
program_name=$(basename "${0}")
cat <<EOF

Please add option switch to end of script:

Example: ./lang_switcher.sh en 

OPTIONS:
  -h        Show this message
  -en       Switch to English
  -fr       Switch to French
EOF
}


AssertSuperUser()
{
    if [ -z "${UID}" ] || [ "${UID}" != 0 ]; then
       echo "You must be root user to perform this operation."
       exit 1
    fi
}

English_to_French ()
{
    AssertSuperUser
    echo "Change UI Interface Language from English to French..."
   # locale set-locale LANG=fr_CA.utf8
    echo "Done. Please reboot UI for change to take effect"
}


French_to_English ()
{
    AssertSuperUser
    echo "Changing UI Interface Language from French to English..."
    #locale set-locale LANG=en_US.utf8
    echo "Done. Please reboot UI for change to take effect"
}


echo "This script will change UI Interface Language between French to English. " 

while true; do

   read -p "Do you wish to continue? " yn

   case $yn in 
        [Yy]* ) while true; 
            do
                case "$1" in
                (en|EN) French_to_English; exit ;;
                (fr|FR) English_to_French; exit ;;
                *) usage; exit ;;
                esac
            done;;
        [Nn]* ) exit ;;
        * ) echo "Please answer yes or no.";; 
        
    esac
done

