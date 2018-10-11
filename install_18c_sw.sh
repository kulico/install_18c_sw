yum install -y oracle-database-preinstall-18c
yum update -y
-----------------------------------------------------------
/sbin/sysctl -p
-----------------------------------------------------------
yum install -y bc    
yum install -y binutils
yum install -y compat-libcap1
yum install -y compat-libstdc++-33
yum install -y compat-libstdc++-33.i686
yum install -y elfutils-libelf.i686
yum install -y elfutils-libelf
yum install -y elfutils-libelf-devel.i686
yum install -y elfutils-libelf-devel
yum install -y fontconfig-devel
yum install -y glibc.i686
yum install -y glibc
yum install -y glibc-devel.i686
yum install -y glibc-devel
yum install -y ksh
yum install -y libaio.i686
yum install -y libaio
yum install -y libaio-devel.i686
yum install -y libaio-devel
yum install -y libX11.i686
yum install -y libX11
yum install -y libXau.i686
yum install -y libXau
yum install -y libXi.i686
yum install -y libXi
yum install -y libXtst.i686
yum install -y libXtst
yum install -y libgcc.i686
yum install -y libgcc
yum install -y librdmacm-devel
yum install -y libstdc++.i686
yum install -y libstdc++
yum install -y libstdc++-devel.i686
yum install -y libstdc++-devel
yum install -y libxcb.i686
yum install -y libxcb
yum install -y make
yum install -y nfs-utils
yum install -y net-tools
yum install -y python
yum install -y python-configshell
yum install -y python-rtslib
yum install -y python-six
yum install -y smartmontools
yum install -y sysstat
yum install -y targetcli
yum install -y unixODBC
-----------------------------------------------------------
groupadd -g 54321 oinstall
groupadd -g 54322 dba
groupadd -g 54323 oper
useradd -u 54321 -g oinstall -G dba,oper 
-----------------------------------------------------------
passwd oracle
welcome1
welcome1
-----------------------------------------------------------
echo "# This file controls the state of SELinux on the system.
# SELINUX= can take one of these three values:
#     enforcing - SELinux security policy is enforced.
#     permissive - SELinux prints warnings instead of enforcing.
#     disabled - No SELinux policy is loaded.
SELINUX=permissive
# SELINUXTYPE= can take one of three two values:
#     targeted - Targeted processes are protected,
#     minimum - Modification of targeted policy. Only selected processes are protected. 
#     mls - Multi Level Security protection.
SELINUXTYPE=targeted" > /etc/selinux/config
-----------------------------------------------------------
setenforce Permissive
-----------------------------------------------------------
systemctl stop firewalld
systemctl disable firewalld
-----------------------------------------------------------
mkdir -p /u01/app/oracle/product/18.0.0/dbhome_1
mkdir -p /u02/oradata
chown -R oracle:oinstall /u01 /u02
chmod -R 775 /u01 /u02
-----------------------------------------------------------
mkdir /home/oracle/scripts
-----------------------------------------------------------
cat > /home/oracle/scripts/setEnv.sh <<EOF
# Oracle Settings
export TMP=/tmp
export TMPDIR=\$TMP

export ORACLE_HOSTNAME=automateJK
export ORACLE_UNQNAME=jellybear18c
export ORACLE_BASE=/u01/app/oracle
export ORACLE_HOME=\$ORACLE_BASE/product/18.0.0/dbhome_1
export ORA_INVENTORY=/u01/app/oraInventory
export ORACLE_SID=jellybear18c
export PDB_NAME=pdb1
export DATA_DIR=/u02/data

export PATH=/usr/sbin:/usr/local/bin:\$PATH
export PATH=\$ORACLE_HOME/bin:\$PATH

export LD_LIBRARY_PATH=\$ORACLE_HOME/lib:/lib:/usr/lib
export CLASSPATH=\$ORACLE_HOME/jlib:\$ORACLE_HOME/rdbms/jlib
EOF
-----------------------------------------------------------
echo ". /home/oracle/scripts/setEnv.sh" >> /home/oracle/.bash_profile
-----------------------------------------------------------
cat > /home/oracle/scripts/start_all.sh <<EOF
#!/bin/bash
. /home/oracle/scripts/setEnv.sh

export ORAENV_ASK=NO
. oraenv
export ORAENV_ASK=YES

dbstart \$ORACLE_HOME
EOF
-----------------------------------------------------------
cat > /home/oracle/scripts/stop_all.sh <<EOF
#!/bin/bash
. /home/oracle/scripts/setEnv.sh

export ORAENV_ASK=NO
. oraenv
export ORAENV_ASK=YES

dbshut \$ORACLE_HOME
EOF
-----------------------------------------------------------
chown -R oracle:oinstall /home/oracle/scripts
chmod u+x /home/oracle/scripts/*.sh
-----------------------------------------------------------
--transfer file to /oracle/home/
cd /oracle/home/
chown oracle:oinstall LINUX.X64_180000_db_home.zip
-----------------------------------------------------------
cd /u01/app/oracle/product/18.0.0/dbhome_1/
unzip -oq /home/oracle/LINUX.X64_180000_db_home.zip
chown -R oracle:oinstall /u01/app/oracle/product/18.0.0/dbhome_1/
chmod 775 runInstaller
----------------------------------------------------------
./runInstaller -ignorePrereq -waitforcompletion -showProgress -silent \
    -responseFile ${ORACLE_HOME}/install/response/db_install.rsp \
    oracle.install.option=INSTALL_DB_SWONLY \
    ORACLE_HOSTNAME=${ORACLE_HOSTNAME} \
    UNIX_GROUP_NAME=oinstall \
    INVENTORY_LOCATION=${ORA_INVENTORY} \
    SELECTED_LANGUAGES=en \
    ORACLE_HOME=${ORACLE_HOME} \
    ORACLE_BASE=${ORACLE_BASE} \
    oracle.install.db.InstallEdition=EE \
    oracle.install.db.OSDBA_GROUP=dba \
    oracle.install.db.OSBACKUPDBA_GROUP=dba \
    oracle.install.db.OSDGDBA_GROUP=dba \
    oracle.install.db.OSKMDBA_GROUP=dba \
    oracle.install.db.OSRACDBA_GROUP=dba \
    SECURITY_UPDATES_VIA_MYORACLESUPPORT=false \
    DECLINE_SECURITY_UPDATES=true
----------------------------------------------------------
su -
# sh /u01/app/oraInventory/orainstRoot.sh
# sh /u01/app/oracle/product/18.0.0/dbhome_1/root.sh