CREATE PROCEDURE uspQMGetTemplateLotStatus @intProductId INT
	,@intSampleTypeId INT
AS
SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

SELECT P.intProductId
	,ISNULL(P.intApprovalLotStatusId, ST.intApprovalLotStatusId) AS intApprovalLotStatusId
	,ISNULL(P.intRejectionLotStatusId, ST.intRejectionLotStatusId) AS intRejectionLotStatusId
	,ISNULL(L1.strSecondaryStatus, L3.strSecondaryStatus) AS strApprovalLotStatus
	,ISNULL(L2.strSecondaryStatus, L4.strSecondaryStatus) AS strRejectionLotStatus
FROM tblQMProduct P
JOIN tblQMProductControlPoint PC ON PC.intProductId = P.intProductId
	AND P.intProductId = @intProductId
	AND PC.intSampleTypeId = @intSampleTypeId
LEFT JOIN tblICLotStatus L1 ON L1.intLotStatusId = P.intApprovalLotStatusId
LEFT JOIN tblICLotStatus L2 ON L2.intLotStatusId = P.intRejectionLotStatusId
LEFT JOIN tblQMSampleType ST ON ST.intSampleTypeId = PC.intSampleTypeId
LEFT JOIN tblICLotStatus L3 ON L3.intLotStatusId = ST.intApprovalLotStatusId
LEFT JOIN tblICLotStatus L4 ON L4.intLotStatusId = ST.intRejectionLotStatusId
