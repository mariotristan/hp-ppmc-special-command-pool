# Synopsis: This script is used to generate new stubs if WSDL/xsd files under conf are modified 
# 
# Example:
#   wsdl2java DemandService
#   wsdl2java ProjectService
# 

# get WS Client Home
ORIG_DIR=`pwd`
BIN_DIR=`dirname $0`

# setup classpath
. $BIN_DIR/setEnv.sh

# set WSDL file name
WSDL_FILE=$CURRPWD/conf/wsdl/$1.wsdl

# set service name
SERVICE_NAME=$1

# set target directory
TARGET_DIR=$CURRPWD/client/stubs

# set default package name
DEFAULT_PACKAGE_DM=com.mercury.itg.ws.dm
DEFAULT_PACKAGE_PM=com.mercury.itg.ws.pm.client
DEFAULT_PACKAGE_RM=com.mercury.itg.ws.rm.client
DEFAULT_PACKAGE_TM=com.mercury.itg.ws.tm.client
DEFAULT_PACKAGE_FM=com.mercury.itg.ws.fm.client


# ==========================
# set namespace mapping
#
# Note: you don't need to change this mapping when generate
#       stubs for different services
# 


# map for common
NS_PACKAGE_MAP=http://mercury.com/ppm/common/1.0=com.mercury.itg.ws.common.client

# map for dm
NS_PACKAGE_MAP=$NS_PACKAGE_MAP,http://mercury.com/ppm/dm/service/1.0=com.mercury.itg.ws.dm.client,http://mercury.com/ppm/dm/1.0=com.mercury.itg.ws.dm.client

# map for pm 
NS_PACKAGE_MAP=$NS_PACKAGE_MAP,http://mercury.com/ppm/pm/1.0=com.mercury.itg.ws.pm.client,http://mercury.com/ppm/pm/service/1.0=com.mercury.itg.ws.pm.client,http://www.mercury.com/ppm/pm/service/1.0=com.mercury.itg.ws.pm.client

# map for tm
NS_PACKAGE_MAP=$NS_PACKAGE_MAP,http://mercury.com/ppm/tm/1.0=com.mercury.itg.ws.tm.client,http://mercury.com/ppm/tm/service/1.0=com.mercury.itg.ws.tm.client

# map for rm
NS_PACKAGE_MAP=$NS_PACKAGE_MAP,http://www.mercury.com/ppm/rm/1.0=com.mercury.itg.ws.rm.client,http://mercury.com/ppm/rm/service/1.0=com.mercury.itg.ws.rm.client,http://mercury.com/ppm/rm/1.0=com.mercury.itg.ws.rm.client

# map for fm
NS_PACKAGE_MAP=$NS_PACKAGE_MAP,http://www.mercury.com/ppm/fm/1.0=com.mercury.itg.ws.fm.client,http://mercury.com/ppm/fm/service/1.0=com.mercury.itg.ws.fm.client,http://mercury.com/ppm/fm/1.0=com.mercury.itg.ws.fm.client

# end of mapping
# ========================


# generate the stub source
echo generatig stubs ...
java -classpath $CPATH org.apache.axis2.wsdl.WSDL2Java -d xmlbeans -uri $WSDL_FILE -sd -g -o $TARGET_DIR -p $DEFAULT_PACKAGE_DM -ssi -ns2p $NS_PACKAGE_MAP -sn $SERVICE_NAME

# compile stubs
echo compiling ...
cd $TARGET_DIR
find . -name *.java > $BIN_DIR/class.list
javac -classpath $CPATH -d $CURRPWD/client/classes -sourcepath $TARGET_DIR/src @$BIN_DIR/class.list
rm -f $BIN_DIR/class.list
cd $ORIG_DIR
