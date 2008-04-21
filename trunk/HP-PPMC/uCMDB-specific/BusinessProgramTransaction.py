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

mam_utils = MamUtils('BusinessProgramTransaction.py')

# 1 ##############################	
if mam_utils.isInfoEnabled():
	mam_utils.info('----- Start Transaction->Program')
# 2 ##############################
########################################### Oracle Data
sid				= Framework.getDestinationAttribute('database_sid')
port				= Framework.getDestinationAttribute('database_port')
ip				= Framework.getDestinationAttribute('database_ip')
hostId				= Framework.getDestinationAttribute('hostId')
oracle_id				= Framework.getDestinationAttribute('id')
credential_id				= Framework.getDestinationAttribute('oracle_credential_id')
########################################### ITG Data
TABLE_USER 			= Framework.getDestinationAttribute('table_user')
VIEW_NAME   			= Framework.getDestinationAttribute('view_name')
TABLE_NAME 			= Framework.getDestinationAttribute('table_name')
REQUEST_TYPE_NAME 			= Framework.getDestinationAttribute('request_type_name')
RELATED_REQUEST_TYPE_NAME 		= Framework.getDestinationAttribute('related_request_type_name')
RELATION_TYPE_NAME			= Framework.getDestinationAttribute('relation_type_name')
RELATION_PARENT_TYPE_NAME		= Framework.getDestinationAttribute('relation_parent_type_name')
########################################### MAM Data
ci_type				= Framework.getDestinationAttribute('ci_type')
sap_transaction_name			= Framework.getDestinationAttribute('sap_transaction_name')
########################################### Object State Holder
oracleOSH 				= ObjectStateHolder('oracle', 6, oracle_id, AppilogTypes.CMDB_OBJECT_ID)
sap_transaction_id			= Framework.getDestinationAttribute('id')
sap_transactionOSH 			= ObjectStateHolder('sap_transaction', 6, sap_transaction_id, AppilogTypes.CMDB_OBJECT_ID)
properties 			= Properties()
properties.setProperty(Protocol.PROTOCOL_ATTRIBUTE_PORT, port)
properties.setProperty(Protocol.SQL_PROTOCOL_ATTRIBUTE_DBSID, sid)
dbRelation="select ci.cmdb_id, des.a_data_name, ci.a_program from cmdb.cdm_sap_transaction_1 ci,cmdb.cdm_data_1 des where ci.cmdb_id=des.cmdb_id and des.a_data_name='%s'"%(sap_transaction_name)
mam_utils.debug('----- SQL: ' ,dbRelation)

# 3 ##############################
def parseDbRelation(dbRelationRes):
		if dbRelationRes:
			rows = dbRelationRes.getRowCount()
			cols = dbRelationRes.getColumnCount()
			for row in range(rows):
				cmdbID 		= dbRelationRes.getCell(row, 0)
				transactionName	= dbRelationRes.getCell(row, 1)
				programName	= dbRelationRes.getCell(row, 2)
				dbChildOSH		= ObjectStateHolder('SAPCCM_ALM_Program',6)	
				dbChildOSH.setAttribute(AttributeStateHolder('data_name', programName, 0,'String'))
				##dbChildOSH.setContainer('root_container', oracleOSH)
				linkOSH = HostKeyUtil.getLink('IS_PROGRAM', dbChildOSH,sap_transactionOSH)
				OSHVSResult.add(linkOSH)
def discoverOracle(sqlAgent, ip, oracleOSH):
		dbRelationRes = doQuery(sqlAgent, dbRelation, ip)
		parseDbRelation(dbRelationRes)
def doQuery(sqlAgent, query, ip):
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

# 4 ##############################
try:
	sqlAgent = Framework.getAgent(AgentConstants.ORACLE_AGENT, ip , credential_id, properties)
except:
	stacktrace = traceback.format_exception(sys.exc_info()[0], sys.exc_info()[1], sys.exc_info()[2])
	if mam_utils.isDebugEnabled():
		mam_utils.debug('Unexpected Framework.getAgent() Exception:')
		mam_utils.debug(stacktrace)
else:
# 5 ##############################
	discoverOracle(sqlAgent, ip, oracleOSH)  
