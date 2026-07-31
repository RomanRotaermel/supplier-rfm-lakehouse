variable "spark_worker_count" {
  description = "Number of Spark worker nodes"
  type        = number
  default     = 1
}

resource "docker_container" "spark_master" {
  name    = "spark-master"
  image   = "apache/spark:4.1.3"
  restart = "always"

  command = ["/opt/spark/bin/spark-class", "org.apache.spark.deploy.master.Master"]

  volumes {
    host_path      = "${abspath(path.root)}/spark"
    container_path = "/opt/spark_files"
  }

  ports {
    internal = 8080
    external = 8082
  }
  ports {
    internal = 7077
    external = 7077
  }

  networks_advanced {
    name = docker_network.data_network.name
  }
}

resource "docker_container" "spark_worker" {
  count = var.spark_worker_count

  name    = "spark-worker-${count.index + 1}"
  image   = "apache/spark:4.1.3"
  restart = "always"

  command = [
    "/opt/spark/bin/spark-class",
    "org.apache.spark.deploy.worker.Worker",
    "spark://spark-master:7077"
  ]

  volumes {
    host_path      = "${abspath(path.root)}/spark"
    container_path = "/opt/spark_files"
  }

  networks_advanced {
    name = docker_network.data_network.name
  }

  depends_on = [docker_container.spark_master]
}
