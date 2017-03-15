CREATE VIEW [dbo].[vyuTFGetReportingComponentVendor]
	AS
SELECT RCV.intReportingComponentVendorId,
	   RC.intReportingComponentId,
	   RCV.intVendorId,
	   RCV.strVendorName,
	   RCV.ysnInclude
FROM tblTFReportingComponentVendor RCV
LEFT JOIN tblTFReportingComponent RC ON RC.intReportingComponentId = RCV.intReportingComponentId
