CREATE VIEW [dbo].[vyuTFGetReportingComponentTransactionSource]
	AS
SELECT RCTS.intReportingComponentTransactionSourceId,
	   RC.intReportingComponentId,
	   TS.strTransactionSource,
	   RCTS.ysnInclude
FROM tblTFReportingComponentTransactionSource RCTS
LEFT JOIN tblTFReportingComponent RC ON RC.intReportingComponentId = RCTS.intReportingComponentId
INNER JOIN tblTFTransactionSource TS ON TS.intTransactionSourceId = RCTS.intTransactionSourceId

