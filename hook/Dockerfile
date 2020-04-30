FROM google/cloud-sdk:latest
add provision.sh /scripts/provision.sh 
RUN chmod 777 /scripts/provision.sh
CMD ["/bin/sh","-c","/scripts/provision.sh"]