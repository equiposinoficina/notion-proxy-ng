# create crawler image:
curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

# run crawler alone, just for testing
sudo docker-compose run --rm crawler -v

# run the crowler with the selenium server
sudo docker-compose up && sudo docker-compose down

# clean selenium session
# sesion_id is available in the web interface of selenium, http://localhost:4444
curl -v --request DELETE 'http://localhost:4444/se/grid/node/session/<session_id>' --header 'X-REGISTRATION-SECRET;'