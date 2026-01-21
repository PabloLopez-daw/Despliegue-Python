#!/bin/bash

# 1. Instalación de paquetes del sistema
echo "Instalando paquetes del sistema..."
sudo apt-get update
sudo apt-get install -y python3-pip nginx git

# 2. Instalación de paquetes de Python (con PATH corregido)
echo "Instalando Pipenv..."
pip3 install pipenv
export PATH=$PATH:/home/vagrant/.local/bin
echo 'export PATH=$PATH:/home/vagrant/.local/bin' >> /home/vagrant/.bashrc

# 3. Preparación del directorio de la aplicación
echo "Configurando directorios..."
sudo mkdir -p /var/www/app
sudo chown -R vagrant:www-data /var/www/app
sudo chmod -R 775 /var/www/app

# 4. Configuración del entorno y Pipenv
echo "Creando archivo .env e instalando dependencias..."
cd /var/www/app
cat <<EOF > .env
FLASK_APP=wsgi.py
FLASK_ENV=production
EOF

# Instalamos flask y gunicorn usando pipenv
sudo -u vagrant /home/vagrant/.local/bin/pipenv install flask gunicorn

# 5. Crear la aplicación de prueba (PoC)
echo "Creando archivos Python..."
cat <<EOF > application.py
from flask import Flask
app = Flask(__name__)
@app.route('/')
def index():
    return '<h1>App desplegada</h1>'
EOF

cat <<EOF > wsgi.py
from application import app
if __name__ == '__main__':
   app.run(debug=False)
EOF

# 6. Obtener la ruta de Gunicorn automáticamente para el servicio
GUNICORN_PATH=$(sudo -u vagrant /home/vagrant/.local/bin/pipenv run which gunicorn)
BIN_PATH=$(dirname "$GUNICORN_PATH")

# 7. Crear el servicio Systemd
echo "Configurando servicio Systemd..."
sudo cat <<EOF > /etc/systemd/system/flask_app.service
[Unit]
Description=flask app service - App con flask y Gunicorn
After=network.target

[Service]
User=vagrant
Group=www-data
Environment="PATH=$BIN_PATH"
WorkingDirectory=/var/www/app
ExecStart=$GUNICORN_PATH --workers 3 --bind unix:/var/www/app/app.sock wsgi:app

[Install]
WantedBy=multi-user.target
EOF

# Activar y arrancar servicio
sudo systemctl daemon-reload
sudo systemctl enable flask_app
sudo systemctl start flask_app

echo "¡Provisión finalizada con éxito!"