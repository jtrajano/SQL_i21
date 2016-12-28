CREATE VIEW [dbo].[vyuTFGetReportingComponent]
	AS
	
SELECT RC.intReportingComponentId
	, RC.intTaxAuthorityId
	, TA.strTaxAuthorityCode
	, RC.strFormCode
	, RC.strFormName
	, RC.strScheduleCode
	, RC.strScheduleName
	, RC.strType
	, RC.strNote
	, RC.strTransactionType
	, RC.intPositionId
	, RC.strSPInventory
	, RC.strSPInvoice
	, RC.strSPRunReport
	, RC.ysnIncludeSalesFreightOnly
FROM tblTFReportingComponent RC
LEFT JOIN tblTFTaxAuthority TA ON TA.intTaxAuthorityId = RC.intTaxAuthorityId