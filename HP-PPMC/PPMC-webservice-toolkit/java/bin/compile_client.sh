# Synopsis: This script is used to compile all classes under client/src 
# 
# Example:
#         complie_client 
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
mkdir -p $DEST_PATH

# compiling ...
cd $SOURCE_PATH
find . -name *.java > $BIN_DIR/class.list
javac -classpath $CPATH -d $DEST_PATH -sourcepath $SOURCE_PATH @$BIN_DIR/class.list
rm -f $BIN_DIR/class.list

# restore work directory
cd $ORIG_DIR

# java -Dclient.repository.dir=$CURRPWD -classpath $CPATH examples.dm.DemandServiceClient http://localhost:8080/itg/ppmservices/DemandService
# java -Dclient.repository.dir=$CURRPWD -classpath $CPATH examples.pm.ProjectServiceClient http://localhost:8080/itg/ppmservices/ProjectService ProjectName
# java -Dclient.repository.dir=$CURRPWD -classpath $CPATH examples.fm60.BudgetServiceClient http://localhost:8080/itg/services/Finance admin admin create TestBudgetName


