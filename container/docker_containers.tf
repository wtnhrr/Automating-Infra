# ----------------------------------------------------------- #

terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 2.22.0"
    }
  }
}

provider "docker" {}

# Criar uma rede Docker compartilhada para os contêineres
resource "docker_network" "shared_network" {
  name = "shared_network"
}

# ----------------------------------------------------------- #

# Nginx
resource "docker_image" "nginx" {
  name = "nginx:latest"
}

resource "docker_container" "nginx" {
  name  = "nginx-container"
  image = docker_image.nginx.name
  networks_advanced {
    name = docker_network.shared_network.name
  }
  ports {
    internal = 80
    external = 8080
  }
}

# ----------------------------------------------------------- #

# PostgreSQL
resource "docker_image" "postgresql" {
  name = "postgres:14"
}

resource "docker_container" "postgresql" {
  name  = "postgresql-container"
  image = docker_image.postgresql.name
  env = [
    "POSTGRES_USER=my_user",
    "POSTGRES_PASSWORD=my_password",
    "POSTGRES_DB=my_database"
  ]
  networks_advanced {
    name = docker_network.shared_network.name
  }
  ports {
    internal = 5432
    external = 5432
  }
}

# ----------------------------------------------------------- #

# Tomcat
resource "docker_image" "tomcat" {
  name = "tomcat:9.0"
}

resource "docker_container" "tomcat" {
  name  = "tomcat-container"
  image = docker_image.tomcat.name
  networks_advanced {
    name = docker_network.shared_network.name
  }
  ports {
    internal = 8080
    external = 8081
  }
}

# ----------------------------------------------------------- #