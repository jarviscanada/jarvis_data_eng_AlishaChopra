#!bin/bash
sudo systemctl status docker || systemctl start docker
options=$1
username=$2
password=$3
container="jrvs-psql"
containercheckvalue=0 

function checkContainerStatusRunning(){
	if [  "$(docker container inspect -f '{{.State.Status}}' $container)" == "running" ]
	then
		echo true
	else
		echo false
	fi
}

function checkContainerStatusExited(){
        if [  "$(docker container inspect -f '{{.State.Status}}' $container)" == "exited" ]
        then
                echo true
        else
                echo false
        fi
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
		containercheckvalue="$(docker container ls -a -f name=$container | wc -l)"
		if [[ $containercheckvalue == 2 ]]
		then
     			echo "postgres container exists"
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
		if [ $(checkContainerStatusRunning) == "true" ]
		then
			echo "container created successfully"
		else
			echo "container not  created successfully"
			exit 1
		fi
			
		
	;;	
	#to start postgres container
	start)
		#function call to get status of container    
		if [ $(checkContainerStatusExited) == "true" ]
		then
			docker start  `docker ps -q -l` # restart it in the background
			docker container start $container
		elif [ $(checkContainerStatusRunning) == "true" ]	
		then
			echo "postgres container has already started"
			exit 1
		else
			"error in starting the conatiner"
			exit 1
		fi		
	;;

	#to stop postgres container
	stop)
		#check if instance is already in exit mode
                if [ $(checkContainerStatusExited) == "true" ]
                then
			echo "Container is already in stop mode"
			exit 1
		#check if the status is running to stop 
		elif [ $(checkContainerStatusRunning) == "true" ]
		then
                        docker container stop $container 
		else 
			echo "Error in stopping instance"
			exit 1
                fi
	;;
	
	*)
	echo "Not a valid option"
	runMessage
	;;
esac
