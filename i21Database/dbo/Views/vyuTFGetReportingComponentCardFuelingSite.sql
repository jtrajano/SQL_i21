CREATE VIEW [dbo].[vyuTFGetReportingComponentCardFuelingSite]
	AS
SELECT CCFS.intReportingComponentCardFuelingSiteId,
	   RC.intReportingComponentId,
	   CCFS.intSiteId,
	   CFS.strSiteNumber,
	   CCFS.ysnInclude
FROM tblTFReportingComponentCardFuelingSite CCFS
LEFT JOIN tblTFReportingComponent RC ON RC.intReportingComponentId = CCFS.intReportingComponentId
INNER JOIN tblCFSite CFS ON CFS.intSiteId = CCFS.intSiteId