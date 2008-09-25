
# get script directory
BIN_DIR=`dirname $0`

# get current directory
ORIG_DIR=`pwd`

# get ws client home directory
cd $BIN_DIR/..
WSCLIENT_HOME=`pwd`

# go back to original directory
cd $ORIG_DIR

# determine server type. If directory C:/ exists, then it must be windows. 
# Otherwise we assume it's UNIX (or some flavor thereof) such as AIX
if [ -d "c:/" ]; then
   HOST_TYPE=WINDOWS
   CSEP=';'
else
   HOST_TYPE=UNIX
   CSEP=':'
fi
export HOST_TYPE

#
# convert path such as //D/foo/bar to D:/foo/bar
#                      /WinNT to C:/WinNT
# if cygwin is installed on a different drive as the Kintana instance
# convert path such as /cygdrive/d/Kintana/ to d:/Kintana
# if path starts with ".", it will remain as is
convert_path() {
   cd $WSCLIENT_HOME
   echo `java -classpath bin/ConvertPath.jar ConvertPath`
}

CURRPWD=`convert_path`

#
# set classpath
CPATH=${CURRPWD}/conf
CPATH=${CPATH}${CSEP}${CURRPWD}/client/stubs/resources
CPATH=${CPATH}${CSEP}${CURRPWD}/client/classes

# include axis2 jar files
for jar in "$CURRPWD"/lib/axis2/*.jar; do
   CPATH=$CPATH$CSEP$jar
done

for jar in "$CURRPWD"/lib/axis1.1/*.jar; do
   CPATH=$CPATH$CSEP$jar
done

# include rampart jar files
for jar in "$CURRPWD"/lib/rampart/*.jar; do
   CPATH=$CPATH$CSEP$jar
done

# include stubs
CPATH=$CPATH$CSEP${CURRPWD}/lib/ppm/webservice_client.jar
CPATH=$CPATH$CSEP${CURRPWD}/lib/ppm/XBeans-packaged.jar
CPATH=$CPATH$CSEP${CURRPWD}/lib/ppm/knta_classes.jar
