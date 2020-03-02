CREATE VIEW vyuIPGetProduct
AS
SELECT P.intProductId
	,P.intConcurrencyId
	,P.intProductTypeId
	,P.intProductValueId
	,P.strDirections
	,P.strNote
	,P.ysnActive
	,P.intApprovalLotStatusId
	,P.intRejectionLotStatusId
	,P.intBondedApprovalLotStatusId
	,P.intBondedRejectionLotStatusId
	,P.intUnitMeasureId
	,P.intCreatedUserId
	,P.dtmCreated
	,P.intLastModifiedUserId
	,P.dtmLastModified
	,P.intProductRefId
	,COALESCE(C.strCategoryCode, I.strItemNo) AS strProductValue
	,LS.strSecondaryStatus AS strApprovalLotStatus
	,LS1.strSecondaryStatus AS strRejectionLotStatus
	,LS2.strSecondaryStatus AS strBondedApprovalLotStatus
	,LS3.strSecondaryStatus AS strBondedRejectionLotStatus
	,UOM.strUnitMeasure
FROM tblQMProduct P WITH (NOLOCK)
LEFT JOIN tblICCategory C WITH (NOLOCK) ON C.intCategoryId = P.intProductValueId
	AND P.intProductTypeId = 1
LEFT JOIN tblICItem I WITH (NOLOCK) ON I.intItemId = P.intProductValueId
	AND P.intProductTypeId = 2
LEFT JOIN tblICLotStatus LS WITH (NOLOCK) ON LS.intLotStatusId = P.intApprovalLotStatusId
LEFT JOIN tblICLotStatus LS1 WITH (NOLOCK) ON LS1.intLotStatusId = P.intRejectionLotStatusId
LEFT JOIN tblICLotStatus LS2 WITH (NOLOCK) ON LS2.intLotStatusId = P.intBondedApprovalLotStatusId
LEFT JOIN tblICLotStatus LS3 WITH (NOLOCK) ON LS3.intLotStatusId = P.intBondedRejectionLotStatusId
LEFT JOIN tblICUnitMeasure UOM WITH (NOLOCK) ON UOM.intUnitMeasureId = P.intUnitMeasureId
