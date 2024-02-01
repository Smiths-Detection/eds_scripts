#!/bin/bash


AssertSuperUser()
{
    if [ -z "${UID}" ] || [ "${UID}" != 0 ]; then
       echo "You must be root user to run this script. Aborting"
       exit 1
    fi
}

STD_TRI_to_BVS_TRI ()
{
    AssertSuperUser
    echo "Converting from Standard TRI to BVS TRI..."
   
	echo "Stopping Postgresql Service"
	systemctl stop postgresql.service
	
	echo "Initializing Postgresql Database"
	rm -rf /var/lib/pgsql/data/
	tar xzvf db.tgz --directory /var/lib/pgsql 1>/dev/null 2>&1
	
	echo "Restarting Postgresql Service"
	systemctl restart postgresql.service
	

	echo "Backup and install new Hosts file"

	if test -f "/etc/hosts.bak"; then
	   
 		echo "Host backup already exists. Skipping.." 

  		
	else
		mv /etc/hosts /etc/hosts.bak
		cp hosts.bvs /etc/hosts
		

	fi

	echo "Done! Please log off and log in as GEEDS and launch PTRI from desktop to replay bag images"


}


BVS_TRI_to_STD_TRI ()
{
	AssertSuperUser
	echo "Converting from BVS TRI to Standard TRI..."
    
	echo "Stopping Postgresql Service"
	systemctl stop postgresql.service
	rm -rf /var/lib/pgsql/data/

	
	echo "Restoring Hosts file"

	if ! test -f "/etc/hosts.bak"; then
	    echo "Host backup missing. Please manually copy hosts file from another TRI and put to /etc/ folder"
	    
	else
		rm /etc/hosts
		mv /etc/hosts.bak /etc/hosts
		

	fi

	echo "Done! The TRI can now be used as a standard TRI or PTRI"

}


echo "This script converts between Standard TRI and BVS TRI (for offline viewing of CTX Bag Images). " 

while true; do

   read -p "------ Do you wish to continue? (Y/N) -------- " yn

   case $yn in 
        [Yy]* ) while true; 
            do
                
		echo "select the operation ************"
		echo "  1) Standard TRI to BVS TRI"
		echo "  2) BVS TRI to Standard TRI"
		read opt
		case $opt in
		  1) STD_TRI_to_BVS_TRI; exit;;
		  2) BVS_TRI_to_STD_TRI; exit;;
		  *) exit ;
		esac
            done;;
        [Nn]* ) exit ;;
        * ) echo "Please answer yes or no.";; 
        
    esac
done
