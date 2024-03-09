#!/bin/bash

#
# Script will read all UIDs from /proc/self/net/* files and map these to the file descriptiors for each process (/proc/*/fd) to map the socket to the PID. Output will contain more info around the process etc. 
# At the moment you two output options: -c csv; verbose description (default)
#
# License
## Free to use, reuse and redistribute for everyone.
## No Limitations.
## Of course attribution is always welcome but not mandatory.
# Author: Mastodon: https://ioc.exchange/@b00010111
# Version: 0.001


convert_ip()
{
  if [ ${#1} -eq 8 ]
  then
    b1=$(echo $((16#$(echo $1| cut -b 7-8))))
    b2=$(echo $((16#$(echo $1| cut -b 5-6))))
    b3=$(echo $((16#$(echo $1| cut -b 3-4))))
    b4=$(echo $((16#$(echo $1| cut -b 1-2))))
    echo "$b1.$b2.$b3.$b4"
  else
    if [ ${#1} -eq 32 ]
    then
      t1=$(echo $1| cut -b 1-8)
      t2=$(echo $1| cut -b 9-16)
      t3=$(echo $1| cut -b 17-24)
      t4=$(echo $1| cut -b 25-32)
      b1="$(echo $t1 | cut -b 7-8)$(echo $t1 | cut -b 5-6):$(echo $t1 | cut -b 3-4)$(echo $t1 | cut -b 1-2)"
      b2="$(echo $t2 | cut -b 7-8)$(echo $t2 | cut -b 5-6):$(echo $t2 | cut -b 3-4)$(echo $t2 | cut -b 1-2)"
      b3="$(echo $t3 | cut -b 7-8)$(echo $t3 | cut -b 5-6):$(echo $t3 | cut -b 3-4)$(echo $t3 | cut -b 1-2)"
      b4="$(echo $t4 | cut -b 7-8)$(echo $t4 | cut -b 5-6):$(echo $t4 | cut -b 3-4)$(echo $t4 | cut -b 1-2)"
      echo "$b1:$b2:$b3:$b4"
    else
      echo "$1"
    fi
   fi
}

main()
{
  for a in $(find /proc/self/net/ -maxdepth 1 -type f);	
  do
    c=$(head -n 1 $a | grep -i 'uid')
    if [ ${#c} -gt 0 ]
    then
      al=$(tail -n +2 $a)
      if [ ${#al} -gt 0 ]
      then
        for u in $(tail -n +2 $a | awk '{print $10}')
        do
          if [ $u -eq 0 ]
          then
            break
          fi
          for i in /proc/*/fd/
          do
            # redirecting stderr, processes might already be gone since the list to itterate was gathered
            if [ "$(ls -l $i 2>/dev/null | grep $u)" ]
            then
              cmdline=$(tr -d '\0' </proc/$(echo $i | tr -d -c 0-9)/cmdline)
              socket_detail=$(grep -i $u $a)
              local_addr=$(echo $socket_detail | awk '{print $2}')
              remote_addr=$(echo $socket_detail | awk '{print $3}')
              local_port_h=$((16#$(echo $local_addr | awk -F: '{print $2'})))
              remote_port_h=$((16#$(echo $remote_addr | awk -F: '{print $2'})))
              local_addr_h=$(convert_ip $(echo $local_addr | awk -F: '{print $1'}))
              remote_addr_h=$(convert_ip $(echo $remote_addr | awk -F: '{print $1'}))
              if [ $csv -eq 1 ]
              then
                echo "$(basename $a),$u,$(echo $i | tr -d -c 0-9),$cmdline,$local_addr_h,$local_port_h,$remote_addr_h,$remote_port_h,$i,$socket_detail"
              else
	              echo "Protocol $(basename $a) has UID: $u found in file description located in $i. Local IP: $local_addr_h Local Port: $local_port_h Remote IP: $remote_addr_h Remote Port: $remote_port_h .Process started with commandline: $cmdline"
              fi
            fi
          done
        done
      fi 
    fi
  done
}

Help()
{
  # Display Help
  echo "Script needs to be run as root."
  echo
  echo "Syntax: scriptTemplate [-c|h]"
  echo "options:"
  echo "h     Print this Help."
  echo "c     Print output as csv."
  echo
}

printCSV_header()
{
  echo "Protocol,UID,PID,cmdline,local_IP,local_Port,remote_IP,remote_port,FileDescriptor_Dir,full_socket_info"
}

csv=0

#check for root permissions
if [ "$EUID" -ne 0 ]
  then 
    echo "Please run as root"
  exit
fi



while getopts ":hc" option; do
  case $option in
    h) # display Help
      Help
      exit;;
    c) # use csv output
      csv=1
      printCSV_header;;
    ?) # Invalid option
      echo "Error: Invalid option"
      Help
      exit;;
  esac
done

main
