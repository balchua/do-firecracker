resource "digitalocean_droplet" "firecracker-server" {
  image = "ubuntu-18-04-x64"
  name = "firecracker-server"
  region = "sgp1"
  size = "s-1vcpu-1gb"
  private_networking = true
  ssh_keys = [
    "${var.digitalocean_ssh_fingerprint}"]

  user_data = "${template_file.firecracker_server_config.rendered}"


  connection {
    user = "root"
    type = "ssh"
    private_key = "${file(var.digitalocean_private_key)}"
    timeout = "2m"
  }

  provisioner "remote-exec" {
    inline = [
      <<EOF
      sudo rm -f /tmp/firecracker.socket
      sudo curl -fsSL -o hello-vmlinux.bin https://s3.amazonaws.com/spec.ccfc.min/img/hello/kernel/hello-vmlinux.bin
      sudo curl -fsSL -o hello-rootfs.ext4 https://s3.amazonaws.com/spec.ccfc.min/img/hello/fsfiles/hello-rootfs.ext4
      mkdir -p /microvm/images
      cp hello-vmlinux.bin /microvm/images
      cp hello-rootfs.ext4 /microvm/images

      #increase the size of the rootfs
      truncate -s 2G /microvm/images/hello-rootfs.ext4
      e2fsck -f /microvm/images/hello-rootfs.ext4
      resize2fs /microvm/images/hello-rootfs.ext4

      chown -R fireman /microvm/*

    EOF
    ]
  }
}

# Controller Container Linux Config
resource "template_file" "firecracker_server_config" {
  template = "${file("${path.module}/templates/firecracker-server.tmpl")}"
}



