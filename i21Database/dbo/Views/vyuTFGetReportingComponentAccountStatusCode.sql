CREATE VIEW [dbo].[vyuTFGetReportingComponentAccountStatusCode]
	AS

SELECT RCAS.intReportingComponentAccountStatusCodeId,
	   RC.intReportingComponentId,
	   RCAS.ysnInclude,
	   RCAS.intAccountStatusId,
	   RCAS.strAccountStatusCode
FROM tblTFReportingComponentAccountStatusCode RCAS
LEFT JOIN tblTFReportingComponent RC ON RC.intReportingComponentId = RCAS.intReportingComponentId
