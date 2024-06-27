#!/bin/bash

# 定义变量
NEW_DATA_DIR=/mnt/new-data
NEW_DEV=/dev/nvme1n1 #需根据实际路径更改
SOURCE_DIR=/mnt/data
#TEMP_FILE=/home/ec2-user/tmp.fstab

# 打印当前块设备信息
sudo lsblk -f

# 检查新设备的文件系统类型
sudo file -s $NEW_DEV

# 格式化新设备为XFS文件系统
sudo mkfs -t xfs $NEW_DEV

# 创建挂载点目录
sudo mkdir -p $NEW_DATA_DIR

# 挂载新设备到新挂载点
sudo mount $NEW_DEV $NEW_DATA_DIR

# 打印挂载信息
sudo df -h

# 使用rsync同步数据
sudo rsync -ax $SOURCE_DIR/ $NEW_DATA_DIR/

# 比较源目录和目标目录的差异
sudo rsync -avn /mnt/data/ $NEW_DATA_DIR

# 卸载/data和/mnt/new-data
sudo umount $SOURCE_DIR
sudo umount $NEW_DATA_DIR

# 挂载新设备到/data
sudo mount $NEW_DEV $SOURCE_DIR

# 获取新设备的UUID(有点问题获取不到，改为通过盘符直接挂载方式)
#UUID=$(blkid -o value -s UUID $NEW_DEV)

# 备份当前的fstab文件
#sudo cp /etc/fstab /etc/fstab.orig

# 创建一个临时文件
#temp_file=$TEMP_FILE

# 循环读取fstab文件的每一行，更新/data的UUID
#while read -r line; do
    #if echo "$line" | grep -q "/data"; then
        #new_line="$(echo "$line" | sed -E "s|UUID=[0-9a-f-]+|UUID=$UUID|")"
        #echo "$new_line" >> "$temp_file"
    #else
        #echo "$line" >> "$temp_file"
    #fi
#done < /etc/fstab

# 用更新后的临时文件替换原始的fstab文件
#sudo cp "$temp_file" /etc/fstab

# 清理临时文件
#rm "$temp_file"
#配置重启自动挂载
echo "$NEW_DEV $SOURCE_DIR xfs defaults 0 0" >> /etc/fstab
echo "The /etc/fstab file has been updated with the new UUID for /data."

# 重启服务器
#sudo reboot

# 断开卷
#aws --region ap-southeast-1 ec2 detach-volume --volume-id vol-0c83818826caf120c
