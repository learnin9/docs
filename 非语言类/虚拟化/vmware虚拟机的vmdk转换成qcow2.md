```
    [root@localhost migration]# qemu-img info SLES11SP1-single.vmdk   
    image: SLES11SP1-single.vmdk   
    file format: vmdk   
    virtual size: 20G (21474836480 bytes)   
    disk size: 3.9G   
      
    [root@localhost migration]# qemu-img convert -f vmdk \  
    -O qcow2 SLES11SP1-single.vmdk SLES11SP1-single.img   
      
    [root@localhost migration]# qemu-img info SLES11SP1-single.img   
    image: SLES11SP1-single.img   
    file format: qcow2   
    virtual size: 20G (21474836480 bytes)   
    disk size: 3.9G   
    cluster_size: 65536  
```