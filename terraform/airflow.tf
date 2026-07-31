resource "docker_container" "airflow_init" {
  name    = "airflow-init"
  image   = "apache/airflow:latest"
  command = ["bash", "-c", "airflow db migrate"]

  env = [
    "AIRFLOW__DATABASE__SQL_ALCHEMY_CONN=postgresql+psycopg2://postgres-airflow:123@postgres-airflow:5432/airflow",
    "AIRFLOW__CORE__EXECUTOR=LocalExecutor",
    "AIRFLOW__CORE__FERNET_KEY=J1DC9K7UjGgBIEUuMFV5cgeje8v82huV4qqjzdSwRIc=", 
    "AIRFLOW_CONN_MINIO_CONN=minio://minioadmin:1234@minio:9000",
    "AIRFLOW__CORE__DAGS_FOLDER=/opt/airflow/dags",
    "AIRFLOW__CORE__SIMPLE_AUTH_MANAGER_USERS=admin:Admin"
  ]

  volumes {
    host_path      = "${abspath(path.root)}/dags"
    container_path = "/opt/airflow/dags"
  }

  networks_advanced {
    name = docker_network.data_network.name
  }

  depends_on = [docker_container.postgres_airflow, docker_container.minio]
}

resource "docker_container" "airflow_webserver" {
  name    = "airflow-webserver"
  image   = "apache/airflow:latest"
  restart = "always"
  command = ["bash", "-c", "airflow api-server"]

  env = [
    "AIRFLOW__DATABASE__SQL_ALCHEMY_CONN=postgresql+psycopg2://postgres-airflow:123@postgres-airflow:5432/airflow",
    "AIRFLOW__CORE__EXECUTOR=LocalExecutor",
    "AIRFLOW__CORE__FERNET_KEY=J1DC9K7UjGgBIEUuMFV5cgeje8v82huV4qqjzdSwRIc=",
    "AIRFLOW_CONN_MINIO_CONN=minio://minioadmin:1234@minio:9000",
    "AIRFLOW__CORE__DAGS_FOLDER=/opt/airflow/dags",
    "AIRFLOW__CORE__SIMPLE_AUTH_MANAGER_USERS=admin:Admin"
  ]

  ports {
    internal = 8080
    external = 8081
  }

  volumes {
    host_path      = "${abspath(path.root)}/dags"
    container_path = "/opt/airflow/dags"
  }

  networks_advanced {
    name = docker_network.data_network.name
  }

  depends_on = [docker_container.airflow_init]
}

resource "docker_container" "airflow_scheduler" {
  name    = "airflow-scheduler"
  image   = "apache/airflow:latest"
  restart = "always"
  command = ["bash", "-c", "airflow scheduler"]

  env = [
    "AIRFLOW__DATABASE__SQL_ALCHEMY_CONN=postgresql+psycopg2://postgres-airflow:123@postgres-airflow:5432/airflow",
    "AIRFLOW__CORE__EXECUTOR=LocalExecutor",
    "AIRFLOW__CORE__FERNET_KEY=J1DC9K7UjGgBIEUuMFV5cgeje8v82huV4qqjzdSwRIc=",
    "AIRFLOW_CONN_MINIO_CONN=minio://minioadmin:1234@minio:9000",
    "AIRFLOW__CORE__DAGS_FOLDER=/opt/airflow/dags",
    "AIRFLOW__CORE__SIMPLE_AUTH_MANAGER_USERS=admin:Admin"
  ]

  volumes {
    host_path      = "${abspath(path.root)}/dags"
    container_path = "/opt/airflow/dags"
  }

  networks_advanced {
    name = docker_network.data_network.name
  }

  depends_on = [docker_container.airflow_init]
}
