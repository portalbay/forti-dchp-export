#!/bin/bash
export PYTHONIOENCODING=utf8
path="/project_path/dhcp"

db_user=$(cat .creds | grep sql | cut -d= -f 2 | cut -f 1 -d ,)
db_pass=$(cat .creds | grep sql | cut -d= -f 2 | cut -f 2 -d ,)

while read line ; do
        site=`echo $line | cut -f1 -d,`
        ip=`echo $line | cut -f2 -d,`
        today=`date +%Y-%m-%d.%H:%M:%S`

	echo "Exporting DHCP list from $site @ $ip..."
	result=`$path/fortigate-dhcp-list.py $site $ip $result>$path/dhcp-list/$site.dhcp`	
done<$path/routers.dat
	
`cat $path/dhcp-list/*.dhcp > $path/dhcp-list/master.csv`
cp $path/dhcp-list/master.csv $path/dhcp-list/archive/master-$today.csv


sql_load_file="$path/dhcp-list/master.csv"
sql="TRUNCATE dhcp;LOAD DATA LOCAL INFILE  '$sql_load_file' INTO TABLE dhcp FIELDS TERMINATED BY ',';"

/usr/bin/mysql -u "$db_user" -p"$db_pass" network -e "$sql"

