job "grafana" {
  datacenters = ["dc1"]
  type        = "service"

  group "grafana" {
    count = 1

    network {
      mode = "host"

      port "http" {
        static = 3000
      }
    }

    volume "grafana-data" {
      type      = "host"
      source    = "grafana-data"
      read_only = false
    }

    task "grafana" {
      driver = "docker"

      config {
        image        = "grafana/grafana:13.3.0"
        network_mode = "host"
      }

      env {
        GF_SERVER_HTTP_ADDR          = "127.0.0.1"
        GF_SERVER_HTTP_PORT          = "3000"
        GF_PATHS_PROVISIONING        = "/local/provisioning"
        GF_USERS_ALLOW_SIGN_UP       = "false"
        GF_AUTH_ANONYMOUS_ENABLED    = "false"
        GF_ANALYTICS_REPORTING_ENABLED = "false"
      }

      template {
        data = file("./config/grafana/provisioning/datasources/datasources.yml")
        destination = "local/provisioning/datasources/datasources.yml"
      }

      template {
        data = file("./config/grafana/provisioning/dashboards/providers.yml")
        destination = "local/provisioning/dashboards/providers.yml"
      }

      template {
        data = file("./dashboards/nomad-observability.json")
        destination = "local/dashboards/nomad-observability.json"
      }

      volume_mount {
        volume      = "grafana-data"
        destination = "/var/lib/grafana"
        read_only   = false
      }

      resources {
        cpu    = 300
        memory = 768
      }
    }
  }
}
