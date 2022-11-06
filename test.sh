echo 0 > /proc/sys/kernel/hung_task_timeout_secs
service mysql stop
umount /var/lib/mysql
mkfs.f2fs -f /dev/sdc1
rmmod f2fs
insmod /home/ubuntu/workspace/linux-4.13/fs/f2fs/f2fs.ko

service mysql start
cp -R /var/lib/mysql/* /mnt/

service mysql stop
mount -o mode=lfs /dev/sdc1 /var/lib/mysql
echo "mounted" | tee tpcc.txt
cp -R /mnt/* /var/lib/mysql/
chown -R mysql:mysql /var/lib/mysql
chmod -R 700 /var/lib/mysql

echo start | tee -a tpcc.txt
cat /proc/diskstats | grep sdc1 | tee -a tpcc.txt
cat /sys/kernel/debug/f2fs/status | tee -a tpcc.txt
df -Th --block-size M | tee -a tpcc.txt

service mysql start
service mysql status | tee -a tpcc.txt
mysqladmin create tpcc1000
mysql tpcc1000 < create_table.sql
mysql tpcc1000 < add_fkey_idx.sql
./tpcc_load -h127.0.0.1 -d tpcc1000 -u root -p "" -w 6 | tee -a tpcc.txt
./tpcc_start -h127.0.0.1 -P3306 -dtpcc1000 -uroot -w6 -c32 -r10 -l100 | tee -a tpcc.txt

cat /proc/diskstats | grep sdc1 | tee -a tpcc.txt
cat /sys/kernel/debug/f2fs/status | tee -a tpcc.txt
df -Th --block-size M | tee -a tpcc.txt
echo end | tee -a tpcc.txt