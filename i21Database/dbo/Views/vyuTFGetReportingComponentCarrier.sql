CREATE VIEW [dbo].[vyuTFGetReportingComponentCarrier]
	AS
SELECT SV.intReportingComponentCarrierId,
	   RC.intReportingComponentId,
	   SV.intEntityId,
	   SV.strShipVia,
	   SV.ysnInclude
FROM tblTFReportingComponentCarrier SV
LEFT JOIN tblTFReportingComponent RC ON RC.intReportingComponentId = SV.intReportingComponentId
INNER JOIN tblSMShipVia ESV ON ESV.intEntityId = SV.intEntityId