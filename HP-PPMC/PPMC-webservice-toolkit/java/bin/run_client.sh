# Synopsis: This script is used to run sample web service client under client/src 
# 
# Example:
#   run_client examples.dm.DemandServiceClient http://localhost:8080/itg/ppmservices/DemandService
#   run_client examples.pm.ProjectServiceClient http://localhost:8080/itg/ppmservices/PorjectService
#   run_client examples.tm.TimeServiceClient http://localhost:8080/itg/ppmservices/TimeService
#   run_client examples.dm.MyDemandServiceClient http://localhost:8080/itg/ppmservices/DemandService
#

# get bin and source path
ORIG_DIR=`pwd`
BIN_DIR=`dirname $0`


# setup classpath
. $BIN_DIR/setEnv.sh

# setup source path
SOURCE_PATH=$CURRPWD/client/src

# setup dest path
DEST_PATH=$CURRPWD/client/classes

# compiling ...
java -classpath $CPATH -Dclient.repository.dir=$CURRPWD $*

# restore work directory
cd $ORIG_DIR

