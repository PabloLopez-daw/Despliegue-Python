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

``` bash
sudo apt-get update
sudo apt-get install -y python3-pip nginx git
pip3 install pipenv
pip3 install python-dotenv
```

## 5. Preparamos del directorio de la aplicacion

``` bash
sudo mkdir -p /var/www/app
sudo chown -R vagrant:www-data /var/www/app
sudo chmod -R 775 /var/www/app
```

## 6. Creamos el archivo .env en /var/www/app y ponemos lo siguiente

``` bash
nano /var/www/app/.env

FLASK_APP=wsgi.py
FLASK_ENV=production
```

## 7. Iniciamos el entorno virtual e instalamos las dependencias

``` bash
cd /var/www/app
pipenv shell

pipenv install flask gunicorn
```

## 8. Creamos dos archivos de prueba

```bash
touch application.py wsgi.py
```

## 9. Le metemos el siguiente contenido a application.py y a wsgi.py

```python
from flask import Flask
app = Flask(__name__)

@app.route('/')
def index():
    '''Index page route'''
    return '<h1>App desplegada</h1>'
```

```python
from application import app

if __name__ == '__main__':
   app.run(debug=False)
```

## 10. Comprobamos el funcionamiento con flask y Gunicorn

```bash
flask run --host '0.0.0.0'
```

```bash
gunicorn --workers 4 --bind 0.0.0.0:5000 wsgi:app
```

## 11. Creamos un servicion Systemd, primero copiamos la ruta de gunicorns primeramente,despues vamos a crear el flask_app.service y ponemos lo siguiente, y por ultimo activamos el servicio

```bash
which gunicorn
exit
```

```bash
sudo nano /etc/systemd/system/flask_app.servicen

[Unit]
Description=flask app service - App con flask y Gunicorn
After=network.target

[Service]
User=vagrant
Group=www-data
Environment="/home/vagrant/.local/share/virtualenvs/app-1lvW3LzD/bin/gunicorn"
WorkingDirectory=/var/www/app
ExecStart=/home/vagrant/.local/share/virtualenvs/app-1lvW3LzD/bin/gunicorn --workers 3 --b>

[Install]
WantedBy=multi-user.target

```

```bash
sudo systemctl daemon-reload
sudo systemctl enable flask_app
sudo systemctl start flask_app
```

## 12. Creamos un archivo de configuracion de nginx y activamos el sitio

```bash 
sudo nano /etc/nginx/sites-available/app.conf

server {
  listen 80;
  server_name app.izv www.app.izv;

  access_log /var/log/nginx/app.access.log;
  error_log /var/log/nginx/app.error.log;

  location / {
    include proxy_params;
    proxy_pass http://unix:/var/www/app/app.sock;
  }
}
```

```bash
sudo ln -s /etc/nginx/sites-available/app.conf /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl restart nginx
```
