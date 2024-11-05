terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "2.23.1"  # Assurez-vous que cette version est compatible
    }
  }
}

provider "docker" {
  host = "tcp://localhost:2375"  # Assurez-vous que le démon Docker est bien exposé sur ce port sans TLS
}

# Définir le réseau Docker
resource "docker_network" "app_network" {
  name = "app_network"
}

# Déployer l'image NGINX
resource "docker_image" "nginx_image" {
  name = "nginx:latest"
}

resource "docker_container" "http_container" {
  name  = "http"
  image = docker_image.nginx_image.name
  networks_advanced {
    name = docker_network.app_network.name
  }
  ports {
    internal = 80
    external = 8080
  }
  # Attacher le fichier de configuration NGINX comme volume
  volumes {
    host_path      = "C:/Users/LENOVO/Documents/TP4 Docker/Etape 1/app/default.conf"  # Chemin absolu
    container_path = "/etc/nginx/conf.d/default.conf"
  }
  # Attacher le répertoire de l'application
  volumes {
    host_path      = "C:/Users/LENOVO/Documents/TP4 Docker/Etape 1/app"  # Chemin absolu
    container_path = "/app"
  }
}

# Déployer l'image PHP
resource "docker_image" "php_image" {
  name = "php:fpm"
}

resource "docker_container" "script_container" {
  name  = "script"
  image = docker_image.php_image.name
  networks_advanced {
    name = docker_network.app_network.name
  }
  volumes {
    host_path      = "C:/Users/LENOVO/Documents/TP4 Docker/Etape 1/app"  # Chemin absolu
    container_path = "/app"
  }
  command = ["php-fpm"]
}
