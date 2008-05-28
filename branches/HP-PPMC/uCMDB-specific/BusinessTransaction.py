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

mam_utils = MamUtils('BusinessTransaction.py')

# 1 ##############################	
if mam_utils.isInfoEnabled():
	mam_utils.info('----- Start Transaction->BusinessService')
# 2 ##############################
########################################### Oracle Data
sid				= Framework.getDestinationAttribute('database_sid')
port				= Framework.getDestinationAttribute('database_port')
ip				= Framework.getDestinationAttribute('database_ip')
hostId				= Framework.getDestinationAttribute('hostId')
oracle_id				= Framework.getDestinationAttribute('id')
credential_id				= Framework.getDestinationAttribute('oracle_credential_id')
SITE_ID				= Framework.getDestinationAttribute('site_id')
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
siteOSH 				= ObjectStateHolder('sap_system',6,SITE_ID,AppilogTypes.CMDB_OBJECT_ID)
mam_utils.info('----- Start Transaction->BusinessService')
########################################### Object State Holder
oracleOSH 				= ObjectStateHolder('oracle', 6, oracle_id, AppilogTypes.CMDB_OBJECT_ID)
sap_transaction_id			= Framework.getDestinationAttribute('id')
sap_transaction_program			= Framework.getDestinationAttribute('program')
properties 				= Properties()
properties.setProperty(Protocol.PROTOCOL_ATTRIBUTE_PORT, port)
properties.setProperty(Protocol.SQL_PROTOCOL_ATTRIBUTE_DBSID, sid)
dbRelation="select r.request_type_name, r.request_id, r.visible_parameter1, r.parameter50, t.request_id, v.visible_parameter1, v.request_type_name, v.visible_parameter6, (select visible_parameter4 from kcrt_table_entries u where u.request_id=t.request_id and u.parameter50=to_char(r.request_id)  and u.visible_parameter1 like 'IS_SEQUENCE') as seq, t.parameter1 as relid, t.visible_parameter1 as relname from kcrt_requests_v r, kcrt_table_entries t, kcrt_requests_v v where instr(t.parameter50,r.request_id)>0 AND t.request_id=v.request_id AND t.visible_parameter1 like 'IS_TRANSACTION' AND v.visible_parameter1='%s'"%(sap_transaction_name)
if mam_utils.isInfoEnabled():
	mam_utils.info('----- relation-text:',dbRelation)
# 3 ##############################
def parseDbRelation(dbRelationRes):
		if dbRelationRes:
			rows = dbRelationRes.getRowCount()
			cols = dbRelationRes.getColumnCount()
			if mam_utils.isDebugEnabled():
				mam_utils.debug('----- Number of Relations: ' , rows)
			for row in range(rows):
				parentType		= dbRelationRes.getCell(row, 0)
				parentType=parentType.replace(' ','_')
				parentID		= dbRelationRes.getCell(row, 1)
				parentName		= dbRelationRes.getCell(row, 2)
				hier		= dbRelationRes.getCell(row, 3)
				childID		= dbRelationRes.getCell(row, 4)
				childName		= dbRelationRes.getCell(row, 5)
				childType		= dbRelationRes.getCell(row, 6)
				childType=childType.replace(' ','_')
				tag		= dbRelationRes.getCell(row, 7)
				seq		= dbRelationRes.getCell(row, 8)
				relationID		= dbRelationRes.getCell(row, 9)
				relationName		= dbRelationRes.getCell(row, 10)
				relationName=relationName.replace(' ','_')
				#################################################
				## source link end
				#################################################
				sap_transactionOSH 	= ObjectStateHolder('sap_transaction', 6)
				sap_transactionOSH.setAttribute(AttributeStateHolder('data_name', childName, 0, 'String'))
				sap_transactionOSH.setContainer('sap_resource_list', siteOSH)
				#################################################
				## target link end
				#################################################
				dbChildOSH		= ObjectStateHolder(parentType,6)	
				dbChildOSH.setAttribute(AttributeStateHolder('data_name', parentName, 1,'String'))
				#################################################
				## link
				#################################################
				linkOSH = HostKeyUtil.getLink('IS_TRANSACTION',sap_transactionOSH, dbChildOSH)
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