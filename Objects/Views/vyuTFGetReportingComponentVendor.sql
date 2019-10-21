CREATE VIEW [dbo].[vyuTFGetReportingComponentVendor]
	AS
SELECT RCV.intReportingComponentVendorId,
	   RC.intReportingComponentId,
	   RCV.intVendorId,
	   EM.strEntityNo strVendorName,
	   RCV.ysnInclude
FROM tblTFReportingComponentVendor RCV
LEFT JOIN tblTFReportingComponent RC ON RC.intReportingComponentId = RCV.intReportingComponentId
INNER JOIN tblEMEntity EM ON EM.intEntityId  = RCV.intVendorId
