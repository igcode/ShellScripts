#!/bin/bash

## Collects the cases status from Clarify using the Web tool and   ##
## Updates the status field for the clarify's table in the mysql server ##
  
# Mysql connections details

user="xxx";
pass="yyy";
db="zzz";

chain="$HOME/mysql/bin/mysql -u"$user" -p"$pass" -D "$db;

#function to update the case status

update_db()
{
    #$1 case status
    #$2 department
    #$3 query response
       
        echo "update cases set status='$1',department='$2' where idclarify='$3'" | $chain ;
}


for i in `echo "select idclarify from cases where status REGEXP '(Open|Working|Standby|No update!)'" | $chain`;

 do

    #Launch a query to the WEbApi tool  for Clarify

    caso=`/usr/bin/curl -i -s0 -m10 "http://aaa.com:8000/apiclarify/clienteSOAP/Soap.php?caso=$i&accion=statusquo" | /bin/grep @`;

    #Gets the most relevant fields

    status=`echo $caso | cut -f2 -d@`;
    department=`echo $caso | cut -f4 -d@`;

          #r.e. to match the status values

          if [[ $status =~ '(Fixed|Working|Open|Close|Standby)' ]];
         	then update_db $status $department $i;
         	else update_db "No update!" $department $i;
          fi;


 done
