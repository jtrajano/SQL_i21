CREATE VIEW [dbo].[vyuTFGetReportingComponentCustomer]
	AS

SELECT RCC.intReportingComponentCustomerId,
	   RC.intReportingComponentId,
	   RCC.intEntityCustomerId,
	   EM.strEntityNo strCustomerNumber,
	   RCC.ysnInclude
FROM tblTFReportingComponentCustomer RCC
LEFT JOIN tblTFReportingComponent RC ON RC.intReportingComponentId = RCC.intReportingComponentId
INNER JOIN tblEMEntity EM ON EM.intEntityId  = RCC.intEntityCustomerId
