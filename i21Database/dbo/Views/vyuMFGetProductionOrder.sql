CREATE VIEW dbo.vyuMFGetProductionOrder
AS
SELECT BR.intBlendRequirementId
	,BR.strDemandNo
	,W.intWorkOrderId
	,W.strWorkOrderNo
	,W.dtmCreated
	,W.dtmExpectedDate
	,W.intCreatedUserId
	,US.strUserName
	,I.intItemId
	,I.strItemNo
	,I.strDescription
	,W.dblQuantity
	,IU.intItemUOMId
	,UM.intUnitMeasureId
	,UM.strUnitMeasure
	,MC.intManufacturingCellId
	,MC.strCellName
	,WS.strName
	,W.strComment
	,OH.strBOLNo
	,OH.intOrderHeaderId
	,OS.strOrderStatus
	,W.intLocationId
FROM dbo.tblMFWorkOrder W
JOIN dbo.tblMFWorkOrderStatus WS ON WS.intStatusId = W.intStatusId
JOIN dbo.tblMFBlendRequirement BR ON W.intBlendRequirementId = BR.intBlendRequirementId
JOIN dbo.tblICItem I ON W.intItemId = I.intItemId
JOIN dbo.tblICItemUOM IU ON W.intItemUOMId = IU.intItemUOMId
JOIN dbo.tblICUnitMeasure UM ON IU.intUnitMeasureId = UM.intUnitMeasureId
JOIN dbo.tblMFManufacturingCell MC ON W.intManufacturingCellId = MC.intManufacturingCellId
JOIN dbo.tblSMUserSecurity US ON W.intCreatedUserId = US.intEntityUserSecurityId
LEFT JOIN dbo.tblWHOrderHeader OH ON W.intOrderHeaderId = OH.intOrderHeaderId
LEFT JOIN dbo.tblWHOrderStatus OS ON OH.intOrderStatusId = OS.intOrderStatusId
WHERE W.intStatusId IN (
		9
		,10
		,11
		)
	AND EXISTS (
		SELECT *
		FROM tblMFWorkOrderInputLot WI
		JOIN tblICItem I ON WI.intItemId = I.intItemId
			AND WI.intWorkOrderId = W.intWorkOrderId
		JOIN tblICCategory C ON I.intCategoryId = C.intCategoryId
			AND C.ysnWarehouseTracked = 1
		)

