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
  name = "nginx:alpine-slim"
}

resource "docker_container" "nginx" {
  name  = "nginx-container"
  image = docker_image.nginx.name
  depends_on = [docker_container.tomcat]
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
  name = "postgres:17-alpine"
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
  name = "tomcat:latest"
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
  depends_on = [docker_network.shared_network]
  env = [
    "DB_USER",
    "DB_PASSWORD",
    "DB_HOST",
    "DB_PORT",
    "DB_NAME"
  ]
}

# ----------------------------------------------------------- #