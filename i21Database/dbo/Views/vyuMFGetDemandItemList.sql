CREATE VIEW vyuMFGetDemandItemList
AS
SELECT DISTINCT I.intItemId
	,I.strItemNo
	,RV.intInvPlngReportMasterID
FROM tblCTInvPlngReportAttributeValue RV
JOIN tblICItem I ON I.intItemId = RV.intItemId
