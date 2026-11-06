job "loki" {
  datacenters = ["dc1"]
  type        = "service"

  group "loki" {
    count = 1

    network {
      mode = "host"

      port "http" {
        static = 3100
      }
    }

    volume "loki-data" {
      type      = "host"
      source    = "loki-data"
      read_only = false
    }

    task "loki" {
      driver = "docker"

      config {
        image        = "grafana/loki:3.7.9"
        network_mode = "host"

        args = [
          "-config.file=/local/loki.yaml",
          "-target=all"
        ]
      }

      template {
        data        = file("./config/loki/loki.yaml")
        destination = "local/loki.yaml"
      }

      volume_mount {
        volume      = "loki-data"
        destination = "/loki"
        read_only   = false
      }

      resources {
        cpu    = 500
        memory = 1024
      }
    }
  }
}
