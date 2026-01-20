# Despliegue-Python
desplegar aplicación con Python


## 1. Creamos una carpeta y hacemos vagrant init
``` bash
vagrant init ubuntu/bionic64
``` 

## 2. Ponemos el siguiente codigo en el vagrantfile , actualizaremos python

``` bash
Vagrant.configure("2") do |config|
  config.vm.box = "ubuntu/bionic64"

  # Red privada (como se explica en la teoría)
  config.vm.network "private_network", ip: "192.168.56.20"

  # Carpeta compartida
  config.vm.synced_folder ".", "/vagrant"

  # Provisionamiento
  config.vm.provision "shell", inline: <<-SHELL
    apt update
    apt install -y python3 python3-pip python3-venv
  SHELL
end
```

## 3. Hacemos un vagrant up y ssh

```bash
vagrant up
vagrant ssh
```


