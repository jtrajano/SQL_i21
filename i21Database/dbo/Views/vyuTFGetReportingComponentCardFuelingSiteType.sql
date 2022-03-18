CREATE VIEW [dbo].[vyuTFGetReportingComponentCardFuelingSiteType]
AS
SELECT RCC.intReportingComponentCardFuelingSiteTypeId,
	   RC.intReportingComponentId,
	   RCC.strTransactionType,
	   RCC.ysnInclude
FROM tblTFReportingComponentCardFuelingSiteType RCC
LEFT JOIN tblTFReportingComponent RC ON RC.intReportingComponentId = RCC.intReportingComponentId