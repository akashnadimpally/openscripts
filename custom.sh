sudo apt-get update
sudo apt-get install docker.io -y
sudo usermod -aG docker $USER   #my case is ubuntu
newgrp docker
sudo chmod 777 /var/run/docker.sock
echo "Docker installation complete."
sudo apt-get update
sudo apt-get install docker-compose -y
sudo docker-compose --version
echo "Docker compose installation complete."

echo "Setting up Splunk.................."

docker pull splunk/splunk:latest
docker run -d -p 8000:8000 -p 9997:9997 -p 8088:8088 -p 8089:8089 -e "SPLUNK_START_ARGS=--accept-license" -e "SPLUNK_PASSWORD=changemeAfter123" --name splunk splunk/splunk:latest

