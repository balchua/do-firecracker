## setup firecracker

After running terraform apply, the firecracker server is ready to run firecracker.
Networking is also setup

from the host system start the firecracker (first terminal):

`rm -f /tmp/firecracker.sock; firecracker --api-sock /tmp/firecracker.sock`


(Second terminal)
### Setup the boot VM kernel

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

### Setup the rootfs

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

### Setup the network interface of firecracker

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
### Start the firecracker microvm

```
curl --unix-socket /tmp/firecracker.sock -i \
    -X PUT 'http://localhost/actions'       \
    -H  'Accept: application/json'          \
    -H  'Content-Type: application/json'    \
    -d '{
        "action_type": "InstanceStart"
     }'
```

(firecracker term)

`ip link set eth0 up      #start the eth0 interface`

`ip addr add 172.17.100.10/24 dev eth0`

`ip route add default via 172.17.100.1 dev eth0`

`sudo echo nameserver 8.8.8.8 > /etc/resolv.conf`
