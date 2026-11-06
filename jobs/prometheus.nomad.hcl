job "prometheus" {
  datacenters = ["dc1"]
  type        = "service"

  group "prometheus" {
    count = 1

    network {
      mode = "host"

      port "http" {
        static = 9090
      }
    }

    volume "prometheus-data" {
      type      = "host"
      source    = "prometheus-data"
      read_only = false
    }

    task "prometheus" {
      driver = "docker"

      config {
        image        = "prom/prometheus:v3.13.5"
        network_mode = "host"

        args = [
          "--config.file=/local/prometheus.yml",
          "--storage.tsdb.path=/prometheus",
          "--storage.tsdb.retention.time=7d",
          "--storage.tsdb.retention.size=2GB",
          "--web.listen-address=127.0.0.1:9090"
        ]
      }

      template {
        data        = file("./config/prometheus/prometheus.yml")
        destination = "local/prometheus.yml"
      }

      volume_mount {
        volume      = "prometheus-data"
        destination = "/prometheus"
        read_only   = false
      }

      resources {
        cpu    = 500
        memory = 768
      }
    }
  }
}
