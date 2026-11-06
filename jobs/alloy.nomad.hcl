job "nomad-log-demo" {
  datacenters = ["dc1"]
  type        = "service"

  group "logging" {
    count = 1

    network {
      mode = "host"

      port "alloy" {
        static = 12345
      }
    }

    task "log-demo" {
      driver = "docker"

      config {
        image   = "busybox:1.37.0"
        command = "/bin/sh"
        args = [
          "-c",
          "while true; do echo \"phase3-log-check $(date -u +%Y-%m-%dT%H:%M:%SZ)\"; sleep 10; done"
        ]
      }

      resources {
        cpu    = 50
        memory = 64
      }
    }

    task "alloy" {
      driver = "docker"

      config {
        image        = "grafana/alloy:v1.21.3"
        network_mode = "host"

        args = [
          "run",
          "--server.http.listen-addr=127.0.0.1:12345",
          "--storage.path=/alloc/data/alloy",
          "/local/config.alloy"
        ]
      }

      template {
        data        = file("./config/alloy/config.alloy")
        destination = "local/config.alloy"
      }

      resources {
        cpu    = 200
        memory = 256
      }
    }
  }
}
