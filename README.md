
# Semi-automatically getting an SSL certificate with Letsencrypt

This documentation leads you through the process of generating a certificate for a domain.

This is an "offline" generation in that it requires the domain to be pointed to a temporary address for certificate generation.

So this works best for getting a temporary (90-day) certificate, or where a domain can be taken offline, rather than for a production domain with rolling certificates.

It's a "get you started" approach.

## Create a VM and log in

Choose your favourite provider. 

The important thing is that the VM is visible from the Internet.

You'll need to map the domain name you want to get a cert for to this VM.

## Install Docker

Install Docker e.g.:
 * https://docs.docker.com/install/linux/docker-ce/debian/
 * https://docs.docker.com/install/linux/linux-postinstall/

Approximately:
    
    sudo apt update
    sudo apt-get install apt-transport-https ca-certificates curl gnupg2 software-properties-common
    curl -fsSL https://download.docker.com/linux/debian/gpg | sudo apt-key add -
    sudo apt-key fingerprint 0EBFCD88
    sudo add-apt-repository \
       "deb [arch=amd64] https://download.docker.com/linux/debian \
       $(lsb_release -cs) \
       stable"
    sudo apt update
    sudo apt install docker-ce
    sudo groupadd docker
    sudo usermod -aG docker $USER

Then log out and log back in again. Hopefully you're all set.


## DNS

Remember to point the DNS name(s) you want to get a certificate for at the VM you've created.


## Run the Letsencrypt container

    mkdir /home/$USER/letsencrypt
    docker run -it --rm -p 80:80 -p 443:443 -v /home/$USER/letsencrypt:/etc/letsencrypt certbot/certbot certonly --standalone --email user@example.com --agree-tos -d example.com -d san.example.com

What we're doing here:
 * Run the container interactively and delete it when it exits
 * Map ports 80 and 443 on the host VM to ports 80 and 443 on the container, so that the container can respond to the challenge from Letsencrypt
 * Map your local letsencrypt directory to /etc/letsencrypt in the container - this ensures you have the output files (including the key and certificate) when the container exits and deletes
 * Pass in configuration options (you can skip these and manually respond to prompts)
 * Each -d value is a domain name to be added to the certificate.


## Collect the certificates

The output of the container will be owned by `root`, so change ownership:

    sudo chown -R $USER:$USER letsencrypt

List the files you need to collect:

    ls letsencrypt/live

Note the full path, log out and then (e.g.) `scp` the files:

   scp -r <VM address>:/home/<user>/letsencrypt/live .


