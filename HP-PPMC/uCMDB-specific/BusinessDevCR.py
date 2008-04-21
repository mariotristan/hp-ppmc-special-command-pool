######################################################
### Discover Change Requests in ITG
### mvdheiden 20070620
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
mam_utils = MamUtils('BusinessDevCR.py')
if mam_utils.isInfoEnabled():
    mam_utils.info('########## Start BusinessDevCR')
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
oracleOSH                     = ObjectStateHolder('oracle', 6, oracle_id, AppilogTypes.CMDB_OBJECT_ID)
if mam_utils.isInfoEnabled():
    mam_utils.info('########## sid: ',sid)
    mam_utils.info('########## port: ',port)
    mam_utils.info('########## host_id: ',host_id)
    mam_utils.info('########## oracle_id: ',oracle_id)
    mam_utils.info('########## ip: ',ip)
    mam_utils.info('########## credential_id: ',credential_id)
    mam_utils.info('########## view_name: ',view_name)
    mam_utils.info('########## request_type_name: ',request_type_name)
    mam_utils.info('########## oracle_id: ',oracle_id)
    mam_utils.info('########## business_id: ',business_id)
    mam_utils.info('########## ci_type: ',ci_type)
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
dbObj                         ="select request_id,description, created_by_username, status_name from %s where request_type_name='%s' "%(view_name,request_type_name)
## dbLink                        ="SELECT request_id FROM mitg.SAPCCM_DEPL_TASKS"

def parseDbObjRes(dbObjRes):
        if dbObjRes:
            rows = dbObjRes.getRowCount()
            cols = dbObjRes.getColumnCount()
            if mam_utils.isDebugEnabled():
                mam_utils.debug('########## sql-statement: ' ,dbObj)
                mam_utils.debug('########## Number of Rows: ' , rows)
                mam_utils.debug('########## Number of Columns: ' , cols)
            for row in range(rows):
                ###################################################
                ### map discovered values to variables
                ###################################################
                data_name           = dbObjRes.getCell(row, 0)
                data_description    = dbObjRes.getCell(row, 1)
                created_by_username = dbObjRes.getCell(row, 2)
                status_name         = dbObjRes.getCell(row, 3)
                # para1               = dbObjRes.getCell(row, 4)
                # vpara1              = dbObjRes.getCell(row, 5)
                # para2               = dbObjRes.getCell(row, 6)
                # vpara2              = dbObjRes.getCell(row, 7)
                # para3               = dbObjRes.getCell(row, 8)
                # vpara3              = dbObjRes.getCell(row, 9)
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
                dbObjOSH.setAttribute(AttributeStateHolder('created_by_username', created_by_username, 0,'String'))
                dbObjOSH.setAttribute(AttributeStateHolder('status_name', status_name, 1,'String'))
                if mam_utils.isDebugEnabled():
                    mam_utils.debug('########## found the following attributes: ' ,dbObj)
                    mam_utils.debug('########## data_name: ' ,data_name)
                    mam_utils.debug('########## data_description: ' ,data_description)
                    mam_utils.debug('########## created_by_username: ' ,created_by_username)
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
        ##dbLinkRes                 = doQuery(sqlAgent, dbLink, ip)
        ##parseDbLinkRes(dbLinkRes)

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