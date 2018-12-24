resource "digitalocean_record" "nfs-server" {
  # DNS zone where record should be created
  domain = "geek.per.sg"
  name = "firecracker-server"
  type = "A"
  ttl = 300
  value = "${digitalocean_droplet.firecracker-server.ipv4_address}"
}

