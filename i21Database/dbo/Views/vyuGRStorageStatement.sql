CREATE VIEW [dbo].[vyuGRStorageStatement]
AS 
SELECT DISTINCT 
	intStorageStatementId = 1
	,strFormNumber		  = SS.strFormNumber
	,dtmIssueDate		  = SS.dtmIssueDate
	,strItemNo			  = SS.strItemNo
	,strStorageType		  = SS.strStorageType
	,strName			  = SV.strName
	,strScheduleId		  = SV.strScheduleId
FROM tblGRStorageStatement SS
JOIN vyuGRStorageSearchView SV 
	ON SV.intCustomerStorageId = (
									SELECT TOP 1 intCustomerStorageId
									FROM tblGRStorageStatement
									WHERE intStorageStatementId = SS.intStorageStatementId
								)


