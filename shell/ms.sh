#!/use/bin/env bash

MASTER_HOST="172.25.0.101"
SLAVE1_HOST="172.25.0.102"
SLAVE2_HOST="172.25.0.103"
SYNC_USER="root"
SYNC_USER_PASS="aq1sw2de"

cat > master.sql <<- EOF
grant replication slave on *.* to 'root'@'172.25.0.%' identified by 'aq1sw2de';
FLUSH PRIVILEGES;
EOF
mysql -uroot -paq1sw2de  < master.sql

SLAVE_LOG_FILE=`mysql -uroot -paq1sw2de -e "show master status;" |grep mysql |awk '{print $1}'`
SLAVE_LOG_POS=`mysql -uroot -paq1sw2de -e "show master status;" |grep mysql |awk '{print $2}'`

cat > slave.sql <<- EOF
stop slave;
change master to master_host='172.25.0.101',master_user='root',master_password='aq1sw2de',master_log_file='$SLAVE_LOG_FILE',master_log_pos=$SLAVE_LOG_POS;
start slave;
EOF
mysql  -u root -paq1sw2de -h $SLAVE1_HOST < slave.sql
mysql  -u root -paq1sw2de -h $SLAVE2_HOST  < slave.sql

exit;
