resource "docker_network" "data_network" {
  name = "data_network"
}

resource "docker_volume" "postgres_data" {
  name = "postgres_data"
}

resource "docker_volume" "postgres_data_airflow" {
  name = "postgres_data_airflow"
}

resource "docker_volume" "minio_data" {
  name = "minio_data"
}