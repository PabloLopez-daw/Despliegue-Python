# Despliegue-Python
desplegar aplicación con Python


## 1. Creamos una carpeta y hacemos vagrant init
``` bash
vagrant init ubuntu/bionic64
``` 

## 2. Ponemos el siguiente codigo en el vagrantfile , actualizaremos python

``` bash
Vagrant.configure("2") do |config|
  config.vm.box = "debian/bullseye64"
  
  # Asignamos una IP privada para acceder desde el navegador
  config.vm.network "private_network", ip: "192.168.33.10"
  
  # Redirigimos el puerto 5000 (Flask dev) y 80 (Nginx) por si acaso
  config.vm.network "forwarded_port", guest: 5000, host: 5000
  config.vm.network "forwarded_port", guest: 80, host: 8080

  config.vm.provider "virtualbox" do |vb|
    vb.memory = "1024"
    vb.cpus = 2
  end
end
```

## 3. Hacemos un vagrant up y ssh

```bash
vagrant up
vagrant ssh
```

## 4. Actualizamos la maquina y descargamos los siguientes paquetes

```bash
sudo apt-get update
sudo apt-get install -y python3-pip nginx git
pip3 install pipenv
pip3 install python-dotenv
```
