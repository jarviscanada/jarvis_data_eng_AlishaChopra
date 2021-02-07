#!bin/bash
sudo systemctl status docker || systemctl start docker
options=$1
username=$2
password=$3
container="jrvs-psql"
containerExistsErr="postgres container exists"
containerDoesNotExistsErr="postgres container does not exists"
containerNotCreated="postgres container is not created"
containercheckvalue=0
status="" 

function containerStatusCheck(){
	echo "$(docker container inspect -f '{{.State.Status}}' $container)"
}

function runMessage()
{
	echo "please use the below options to run the script"
	echo "Step1: To create postgres container ./scripts/psql_docker.sh create db_username db_password"
	echo "Step2: To start postgres container ./scripts/psql_docker.sh start"
	echo "Step3: To stop postgres ./scripts/psql_docker.sh stop"
}
#check if docker is enabled to run through root 
if ! grep -q docker /etc/group
	then 
		sudo groupadd docker
		sudo usermod -aG docker centos
		newgrp docker
	fi
echo "$options $username $password"
#sudo docker container ls -a -f name=jrvs-psql | wc -l
case $options in
	create)
		#check if container exists
		#icontainerExists
		containercheckvalue="$(docker container ls -a -f name=$container | wc -l)"
		if [[ $containercheckvalue == 2 ]]
		then
     			echo "$containerExistsErr"
			exit 1	
		fi
	
		
        	if [ -z "$username" ] || [ -z "$password" ] 
		then
			echo "please provide both username and password"
			runMessage
			exit 1
		fi

		docker pull postgres
		docker volume create pgdata
		docker run --name $container -e POSTGRES_PASSWORD=$password -e POSTGRES_USER=$username -d -v pgdata:/var/lib/postgresql/data -p 5432:5432 postgres		
		exit $?
		
		#function call to check container status 
		
		status=$(containerStatusCheck)
		if [ $status == "running"]
		then
			echo "container created successfully"
		else
			echo "container not  created successfully"
			exit 1
		fi
			
		
	;;	
	#to start postgres container
	start)
		   
		#check if the status is running 
		status=$(containerStatusCheck)
		if [ $status == "exited" ]
		then
			docker start  `docker ps -q -l` # restart it in the background
	#		docker attach `docker ps -q -l` # reattach the terminal & stdin
			docker container start $container
		fi		
		#check if the existing container is running
		if [ $status == "running" ]	
		then
			echo "postgres container has already started"
			exit 1
		fi		
	;;

	#to stop postgres container
	stop)
		status=$(containerStatusCheck)
                #check if the status is running to stop 
                if [ $status == "running" ]
                then
			echo "in docker stop"
                        docker container stop $container 
                fi
	;;
	
	*)
	echo "Not a valid option"
	runMessage
	;;
esac
