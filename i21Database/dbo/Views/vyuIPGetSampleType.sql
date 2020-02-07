﻿CREATE VIEW vyuIPGetSampleType
AS
SELECT ST.intSampleTypeId
	,ST.intConcurrencyId
	,ST.strSampleTypeName
	,ST.strDescription
	,ST.intControlPointId
	,ST.ysnFinalApproval
	,ST.strApprovalBase
	,ST.intSampleLabelId
	,ST.ysnAdjustInventoryQtyBySampleQty
	,ST.intApprovalLotStatusId
	,ST.intRejectionLotStatusId
	,ST.intBondedApprovalLotStatusId
	,ST.intBondedRejectionLotStatusId
	,ST.intCreatedUserId
	,ST.dtmCreated
	,ST.intLastModifiedUserId
	,ST.dtmLastModified
	,ST.intSampleTypeRefId
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
