CREATE VIEW vyuQMSampleTypeNotMapped
AS
SELECT ST.intSampleTypeId
	,CP.strControlPointName
	,SL.strSampleLabelName
	,L1.strSecondaryStatus AS strApprovalLotStatus
	,L2.strSecondaryStatus AS strRejectionLotStatus
	,L3.strSecondaryStatus AS strBondedApprovalLotStatus
	,L4.strSecondaryStatus AS strBondedRejectionLotStatus
FROM tblQMSampleType ST
JOIN tblQMControlPoint CP ON CP.intControlPointId = ST.intControlPointId
LEFT JOIN tblQMSampleLabel SL ON SL.intSampleLabelId = ST.intSampleLabelId
LEFT JOIN tblICLotStatus L1 ON L1.intLotStatusId = ST.intApprovalLotStatusId
LEFT JOIN tblICLotStatus L2 ON L2.intLotStatusId = ST.intRejectionLotStatusId
LEFT JOIN tblICLotStatus L3 ON L3.intLotStatusId = ST.intBondedApprovalLotStatusId
LEFT JOIN tblICLotStatus L4 ON L4.intLotStatusId = ST.intBondedRejectionLotStatusId
