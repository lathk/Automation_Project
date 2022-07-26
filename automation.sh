#!/bin/bash

apt update -y
apt upgrade -y

myname='Latha'
s3_bucket='upgrad-lathak'
timestamp=$(date '+%d%m%Y-%H%M%S')


copy_logs_to_s3_bucket() {
  aws s3 \
  		cp /tmp/${myname}-httpd-logs-${timestamp}.tar \
  		s3://${s3_bucket}/${myname}-httpd-logs-${timestamp}.tar
  echo "Logfiles were archived to s3 bucket : ${s3_bucket}"
}


if [[ $(dpkg --list | grep apache2) =~ 'apache2' ]];
then
  
  echo "Apache2 is installed... checking for its state."
  if [[ $(systemctl status apache2) =~ 'active' ]];
  then
  	echo "Apache2 service is running."
  else
  	echo "Apache2 service is not running... Staring service now."
  	systemctl start apache2
  	echo "Apache2 service is now running."
  fi
  
	if [[ $(systemctl status apache2) =~ 'enabled;' ]];
		then
		  echo "Apache2 service is enabled."
		else
		  echo "Apache2 is not enabled... Enabling now."
		  systemctl enable apache2
		  echo "Apache2 is now enabled."
	fi
else
	echo "Apache2 not installed... Installing Apache2 now"
	printf 'Y\n' | apt install apache2
	echo "Apache2 service is installed... Service is running now."
fi


tar -cvf /tmp/${myname}-httpd-logs-${timestamp}.tar /var/log/apache2/access.log /var/log/apache2/error.log


if [[ $(dpkg --list | grep awscli) =~ 'awscli' ]];
	then
		copy_logs_to_s3_bucket
	else
	  echo "awscli was not installed... Installing now."
	  printf 'Y\n' | apt install awscli
	  echo "awscli is now installed."
	  copy_logs_to_s3_bucket
fi


