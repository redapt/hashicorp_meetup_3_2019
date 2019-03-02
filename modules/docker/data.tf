data "docker_registry_image" "redaptu" {
  name = "iancornett/redaptuniversity:latest"
}

data "docker_registry_image" "mssql" {
  name = "microsoft/mssql-server-linux:latest"
}

data "docker_registry_image" "nginx" {
  name = "nginx:latest"
}