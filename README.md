# Launch AWS Firecracker in DigitalOcean

Pre-requisites:
1.  Terraform v 0.11+
2.  Digital Ocean account

## Setting up the host and install Firecracker

1.  From `src/terraform`, run `terraform apply -auto-approve`.  
   - This will launch a Droplet of 1 vcpu with 1GB RAM.
   - Cloud init stuffs:
     - Download the firecracker binary (v0.12.0).
     - Setup network TAP, so that firecracker VM will have access to the network.  (see `src/terraform/templates/firecracker-server.tmpl`)
     - Increase the `rootfs` to 2GB, otherwise it stays at 28MB, nothing can be done with it. :)
     - Create `fireman` user to launch firecracker.
   
2.  Open 2 terminals by ssh'ing to the Host.  example: `ssh fireman@ipaddress`

## Setup firecracker

First Terminal:
1. Start the firecracker (first terminal)

`rm -f /tmp/firecracker.sock; firecracker --api-sock /tmp/firecracker.sock`

 _This will be in foreground mode._ 

Second terminal:

1. Setup the boot VM kernel

    ```
    curl --unix-socket /tmp/firecracker.sock -i \
        -X PUT 'http://localhost/boot-source'   \
        -H 'Accept: application/json'           \
        -H 'Content-Type: application/json'     \
        -d '{
            "kernel_image_path": "/microvm/images/hello-vmlinux.bin",
            "boot_args": "console=ttyS0 reboot=k panic=1 pci=off"
        }'
    ```

2.  Setup the rootfs

    ```
    curl --unix-socket /tmp/firecracker.sock -i \
        -X PUT 'http://localhost/drives/rootfs' \
        -H 'Accept: application/json'           \
        -H 'Content-Type: application/json'     \
        -d '{
            "drive_id": "rootfs",
            "path_on_host": "/microvm/images/hello-rootfs.ext4",
            "is_root_device": true,
            "is_read_only": false
        }'
    ```

3. Setup the network interface of firecracker

    ```
    curl --unix-socket /tmp/firecracker.sock \
         -X PUT 'http://localhost/network-interfaces/eth0' \
         -H  'Accept: application/json' \
         -H  'Content-type: application/json' \
         -d '{
              "iface_id": "eth0",
              "host_dev_name": "tap0"
         }'
    ```

4. Start the firecracker microvm

    ```
    curl --unix-socket /tmp/firecracker.sock -i \
        -X PUT 'http://localhost/actions'       \
        -H  'Accept: application/json'          \
        -H  'Content-Type: application/json'    \
        -d '{
            "action_type": "InstanceStart"
         }'
    ```

After launching the firecracker **Instance**, you will be prompted to login (user: root password: root)

    ip link set eth0 up      #start the eth0 interface
    ip addr add 172.17.100.10/24 dev eth0
    ip route add default via 172.17.100.1 dev eth0
    echo "nameserver 8.8.8.8" > /etc/resolv.conf

That's it.  If you want to download jdk 11 for Alpine, head on to Zulu (https://cdn.azul.com/zulu/bin/zulu11.2.3-jdk11.0.1-linux_musl_x64.tar.gz)
Install instructions : (https://www.azul.com/downloads/zulu/zulu-download-alpine/)


### Use Ubuntu bionic image instead of Alpine
[TODO] Taken from (https://github.com/bkleiner/ubuntu-firecracker)
