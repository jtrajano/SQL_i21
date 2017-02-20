CREATE VIEW [dbo].[vyuTFGetReportingComponentCustomer]
	AS

SELECT RCC.intReportingComponentCustomerId,
	   RC.intReportingComponentId,
	   RCC.intEntityCustomerId,
	   RCC.strCustomerNumber,
	   RCC.ysnInclude
FROM tblTFReportingComponentCustomer RCC
LEFT JOIN tblTFReportingComponent RC ON RC.intReportingComponentId = RCC.intReportingComponentId