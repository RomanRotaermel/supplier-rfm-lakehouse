resource "docker_container" "postgres_gold" {
  name    = "postgres-gold"
  image   = "postgres:latest"
  restart = "always"

  env = [
    "POSTGRES_USER=postgres-gold",
    "POSTGRES_PASSWORD=12345",
    "POSTGRES_DB=gold_layer" 
  ]

  ports {
    internal = 5432
    external = 5433
  }

  volumes {
    volume_name    = docker_volume.postgres_data.name
    container_path = "/var/lib/postgresql/data_gold"
  }

  networks_advanced {
    name = docker_network.data_network.name
  }

  healthcheck {
    test     = ["CMD-SHELL", "pg_isready -U postgres-gold"]
    interval = "10s"
    timeout  = "5s"
    retries  = 5
  }
}

resource "docker_container" "postgres_airflow" {
  name    = "postgres-airflow"
  image   = "postgres:latest"
  restart = "always"

  env = [
    "POSTGRES_USER=postgres-airflow",
    "POSTGRES_PASSWORD=123",
    "POSTGRES_DB=airflow"  
  ]

  ports {
    internal = 5432
    external = 5432
  }

  volumes {
    volume_name    = docker_volume.postgres_data_airflow.name
    container_path = "/var/lib/postgresql/data_airflow"
  }

  networks_advanced {
    name = docker_network.data_network.name
  }

  healthcheck {
    test     = ["CMD-SHELL", "pg_isready -U postgres-airflow"]
    interval = "10s"
    timeout  = "5s"
    retries  = 5
  }
}
