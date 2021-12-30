#!/bin/bash -xe
exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1
wget https://busybox.net/downloads/binaries/1.28.1-defconfig-multiarch/busybox-x86_64
mv busybox-x86_64 ~/busybox
chmod +x ~/busybox
~/busybox
cat > index.html << EOF
<h1>Hello World</h1>
<p>DB address : ${vars.db_address}</p>
<p>DB port : ${vars.db_port}</p>
EOF

nohup ~/busybox httpd -f -p "${vars.server_port}" &