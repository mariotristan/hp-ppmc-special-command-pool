######################################################
### Discover Change Requests in ITG
### mvdheiden 20070813
######################################################
######################################################
### Imports
######################################################
import sys
import traceback
from ext.MamUtils import MamUtils
from ext.TargetFile import TargetFile
from java.lang import StringBuffer
from java.util import Properties
from java.net import InetAddress
from appilog.common.system.defines import AppilogTypes
from appilog.collectors.services.dynamic.agents import AgentConstants
from appilog.collectors.util import ProtocolDictionaryManager
from appilog.collectors.util import NetworkXmlUtil
from appilog.collectors.util import HostKeyUtil
from appilog.common.utils import Protocol
mam_utils = MamUtils('BusinessGroup.py')
if mam_utils.isInfoEnabled():
    mam_utils.info('########## Start BusinessGroup')
#######################################################
### Define needed variables
### Framework.getDestinationAttribut from pattern settings
### ObjectStateHolder() from CMDB
#######################################################
sid                           = Framework.getDestinationAttribute('database_sid')
port                          = Framework.getDestinationAttribute('database_port')
host_id                       = Framework.getDestinationAttribute('hostId')
oracle_id                     = Framework.getDestinationAttribute('oracle_id')
ip                            = Framework.getDestinationAttribute('database_ip')
credential_id                 = Framework.getDestinationAttribute('oracle_credential_id')
view_name                     = Framework.getDestinationAttribute('view_name')
request_type_name             = Framework.getDestinationAttribute('request_type_name')
oracle_id                     = Framework.getDestinationAttribute('oracle_id')
business_id                   = Framework.getDestinationAttribute('id')
ci_type                       = Framework.getDestinationAttribute('ci_type')
child_ci_type                 = Framework.getDestinationAttribute('child_ci_type')
relation_1                    = Framework.getDestinationAttribute('relation_1')
relation_2                    = Framework.getDestinationAttribute('relation_2')
oracleOSH                     = ObjectStateHolder('oracle', 6, oracle_id, AppilogTypes.CMDB_OBJECT_ID)
if mam_utils.isInfoEnabled():
    mam_utils.info('########## sid,port,oracle,id,ip,credential_id, view_name, request_type_name, oracle_id, business_id,ci_type,child_ci_type: ',sid,port,host_id,oracle_id,ip,credential_id,view_name,request_type_name,oracle_id,business_id,ci_type,child_ci_type)
#######################################################
### Stateholder for the business CI as virtual object
#######################################################
businessOSH                   = ObjectStateHolder('business', 6, business_id, AppilogTypes.CMDB_OBJECT_ID)
properties                    = Properties()
properties.setProperty(Protocol.PROTOCOL_ATTRIBUTE_PORT, port)
properties.setProperty(Protocol.SQL_PROTOCOL_ATTRIBUTE_DBSID, sid)
#######################################################
### select statement for getting the objects
####################################################### 
dbObj                         ="select req.request_id, req.visible_parameter1, req.created_by_name, req.status_name, req.visible_parameter8,req.visible_parameter6 from %s req  where req.request_type_name='%s' "%(view_name,request_type_name)


def parseDbObjRes(dbObjRes):
        if dbObjRes:
            rows = dbObjRes.getRowCount()
            cols = dbObjRes.getColumnCount()
            if mam_utils.isDebugEnabled():
                mam_utils.debug('########## sql-statement, rows, collumns ' ,dbObj,rows,cols)
            for row in range(rows):
                ###################################################
                ### map discovered values to variables
                ###################################################
                data_name           = dbObjRes.getCell(row, 1)
                request_id          = dbObjRes.getCell(row, 0)
                data_description    = dbObjRes.getCell(row, 1)
                created_by_username = dbObjRes.getCell(row, 2)
                status_name         = dbObjRes.getCell(row, 3)
                data_name_en        = dbObjRes.getCell(row, 4)
                identifier          = dbObjRes.getCell(row, 5)
                ####################################################
                ### define object stateholder for discovered CI
                ### ObjectStateHolder([CI-TYPE],6)
                ####################################################
                dbObjOSH        = ObjectStateHolder(ci_type, 6)
                ####################################################
                ### map variables to CI attributes 0=overwrite 1=insert
                ####################################################
                dbObjOSH.setAttribute(AttributeStateHolder('data_name', data_name, 1,'String'))
                dbObjOSH.setAttribute(AttributeStateHolder('data_description', data_description, 0,'String'))
                dbObjOSH.setAttribute(AttributeStateHolder('request_id', request_id, 0,'String'))
                dbObjOSH.setAttribute(AttributeStateHolder('created_by_username', created_by_username, 0,'String'))
                dbObjOSH.setAttribute(AttributeStateHolder('status_name', status_name, 0,'String'))
                dbObjOSH.setAttribute(AttributeStateHolder('data_name_en', data_name_en, 0,'String'))
                dbObjOSH.setAttribute(AttributeStateHolder('identifier', identifier, 0,'String'))
                if mam_utils.isDebugEnabled():
                    mam_utils.debug('########## found the following attributes: data_name,request_id,data_description,created_by,status_name,data_name_en,data_description ' ,dbObj,data_name,request_id,data_description,created_by_username,status_name,data_name_en,data_description,identifier)
                ####################################################
                ### set root_container; needs an defined CMDB GUID f.e. by an object stateholder
                ####################################################
                dbObjOSH.setContainer('root_container', businessOSH)
                ####################################################
                ### add object stateholder with all attributes to CMDB
                ####################################################
                OSHVSResult.add(dbObjOSH)


def discoverOracle(sqlAgent, ip, oracleOSH):
        #################################################
        ### instance that starts the defined parsing
        #################################################
        dbObjRes                  = doQuery(sqlAgent, dbObj, ip)
        parseDbObjRes(dbObjRes)

def doQuery(sqlAgent, query, ip):
        #################################################
        ### instance that starts the defined database request
        #################################################
        tableRes = None
        try:
            tableRes = sqlAgent.doTableCommand( query )
        except:
            stacktrace = traceback.format_exception(sys.exc_info()[0], sys.exc_info()[1], sys.exc_info()[2])
            if mam_utils.isDebugEnabled():
                mam_utils.debug('Failed activating query: ' , query , '\non destination: ' , ip , '\nException:')
                mam_utils.debug(stacktrace)
        if mam_utils.isDebugEnabled():
            if tableRes:
                rows = tableRes.getRowCount()
                cols = tableRes.getColumnCount()
                mam_utils.debug('Found ', rows, ' rows, ', cols, ' columns.')    
            return tableRes

try:
    ######################################################
    ### start the discovery process with defining sqlAgent
    ######################################################
    sqlAgent = Framework.getAgent(AgentConstants.ORACLE_AGENT, ip , credential_id, properties)
except:
    stacktrace = traceback.format_exception(sys.exc_info()[0], sys.exc_info()[1], sys.exc_info()[2])
    if mam_utils.isDebugEnabled():
        mam_utils.debug('Unexpected Framework.getAgent() Exception:')
        mam_utils.debug(stacktrace)
else:
    discoverOracle(sqlAgent, ip, oracleOSH)
