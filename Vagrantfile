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
