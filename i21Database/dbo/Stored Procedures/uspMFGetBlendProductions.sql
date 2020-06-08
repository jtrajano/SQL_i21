CREATE PROCEDURE [dbo].[uspMFGetBlendProductions] @intManufacturingCellId INT
	,@ysnProduced BIT = 0
	,@intLocationId INT = 0
AS
SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

IF ISNULL(@ysnProduced, 0) = 0
	SELECT w.intWorkOrderId
		,w.strWorkOrderNo
		,i.strItemNo
		,i.strDescription
		,ISNULL(w.dblQuantity, 0.0) AS dblQuantity
		,ISNULL(w.dblPlannedQuantity, 0.0) AS dblPlannedQuantity
		,w.intItemUOMId
		,um.strUnitMeasure AS strUOM
		,w.intStatusId
		,w.intManufacturingCellId
		,w.intMachineId
		,w.dtmCreated
		,w.intCreatedUserId
		,w.dtmLastModified
		,w.intLastModifiedUserId
		,w.dtmExpectedDate
		,w.dblBinSize
		,w.intBlendRequirementId
		,w.ysnKittingEnabled
		,w.strComment
		,w.intLocationId
		,w.intStorageLocationId
		,br.strDemandNo
		,ISNULL(ws.strBackColorName, '') AS strBackColorName
		,us.strUserName
		,w.intExecutionOrder
		,ws.strName AS strStatus
		,sl.strName AS strStorageLocation
		,mc.strCellName
		,i.strLotTracking
		,i.intItemId
		,w.strERPOrderNo
		,i.dblRiskScore
		,w.intManufacturingProcessId
		,i.intCategoryId
		,w.intTransactionFrom
	FROM tblMFWorkOrder w
	JOIN tblICItem i ON w.intItemId = i.intItemId
	JOIN tblICItemUOM iu ON w.intItemUOMId = iu.intItemUOMId
	JOIN tblICUnitMeasure um ON iu.intUnitMeasureId = um.intUnitMeasureId
	JOIN tblMFBlendRequirement br ON w.intBlendRequirementId = br.intBlendRequirementId
	JOIN tblMFWorkOrderStatus ws ON w.intStatusId = ws.intStatusId
	JOIN tblMFManufacturingCell mc ON w.intManufacturingCellId = mc.intManufacturingCellId
	LEFT JOIN tblSMUserSecurity us ON w.intCreatedUserId = us.[intEntityId]
	LEFT JOIN tblICStorageLocation sl ON w.intStorageLocationId = sl.intStorageLocationId
	WHERE w.intManufacturingCellId = @intManufacturingCellId
		AND w.intStatusId IN (
			9
			,10
			,11
			,12
			)
		AND ISNULL(w.intTransactionFrom, 0) <> 5 --Exclude Blends Produced/Reversed from Simple Blend Production(4), AutoBlend(5) 
	ORDER BY w.dtmExpectedDate
		,w.intExecutionOrder

--Closed Blend Sheets
IF ISNULL(@ysnProduced, 0) = 1
BEGIN
	IF @intManufacturingCellId > 0
		SELECT w.intWorkOrderId
			,w.strWorkOrderNo
			,i.strItemNo
			,i.strDescription
			,ISNULL(w.dblQuantity, 0.0) AS dblQuantity
			,ISNULL(w.dblPlannedQuantity, 0.0) AS dblPlannedQuantity
			,w.intItemUOMId
			,um.strUnitMeasure AS strUOM
			,w.intStatusId
			,w.intManufacturingCellId
			,w.intMachineId
			,w.dtmCreated
			,w.intCreatedUserId
			,w.dtmLastModified
			,w.intLastModifiedUserId
			,w.dtmExpectedDate
			,w.dblBinSize
			,w.intBlendRequirementId
			,w.ysnKittingEnabled
			,w.strComment
			,w.intLocationId
			,w.intStorageLocationId
			,br.strDemandNo
			,ISNULL(ws.strBackColorName, '') AS strBackColorName
			,us.strUserName
			,w.intExecutionOrder
			,ws.strName AS strStatus
			,sl.strName AS strStorageLocation
			,mc.strCellName
			,i.strLotTracking
			,i.intItemId
			,i.intCategoryId
			,w.intTransactionFrom
		FROM tblMFWorkOrder w
		JOIN tblICItem i ON w.intItemId = i.intItemId
		JOIN tblICItemUOM iu ON w.intItemUOMId = iu.intItemUOMId
		JOIN tblICUnitMeasure um ON iu.intUnitMeasureId = um.intUnitMeasureId
		JOIN tblMFBlendRequirement br ON w.intBlendRequirementId = br.intBlendRequirementId
		JOIN tblMFWorkOrderStatus ws ON w.intStatusId = ws.intStatusId
		JOIN tblMFManufacturingCell mc ON w.intManufacturingCellId = mc.intManufacturingCellId
		LEFT JOIN tblSMUserSecurity us ON w.intCreatedUserId = us.[intEntityId]
		LEFT JOIN tblICStorageLocation sl ON w.intStorageLocationId = sl.intStorageLocationId
		WHERE w.intManufacturingCellId = @intManufacturingCellId
			AND w.intStatusId = 13
		ORDER BY w.dtmCompletedDate DESC
	ELSE
		SELECT w.intWorkOrderId
			,w.strWorkOrderNo
			,i.strItemNo
			,i.strDescription
			,ISNULL(w.dblQuantity, 0.0) AS dblQuantity
			,ISNULL(w.dblPlannedQuantity, 0.0) AS dblPlannedQuantity
			,w.intItemUOMId
			,um.strUnitMeasure AS strUOM
			,w.intStatusId
			,w.intManufacturingCellId
			,w.intMachineId
			,w.dtmCreated
			,w.intCreatedUserId
			,w.dtmLastModified
			,w.intLastModifiedUserId
			,w.dtmExpectedDate
			,w.dblBinSize
			,w.intBlendRequirementId
			,w.ysnKittingEnabled
			,w.strComment
			,w.intLocationId
			,w.intStorageLocationId
			,br.strDemandNo
			,ISNULL(ws.strBackColorName, '') AS strBackColorName
			,us.strUserName
			,w.intExecutionOrder
			,ws.strName AS strStatus
			,sl.strName AS strStorageLocation
			,mc.strCellName
			,i.strLotTracking
			,i.intItemId
			,i.intCategoryId
			,w.intTransactionFrom
		FROM tblMFWorkOrder w
		JOIN tblICItem i ON w.intItemId = i.intItemId
		JOIN tblICItemUOM iu ON w.intItemUOMId = iu.intItemUOMId
		JOIN tblICUnitMeasure um ON iu.intUnitMeasureId = um.intUnitMeasureId
		JOIN tblMFBlendRequirement br ON w.intBlendRequirementId = br.intBlendRequirementId
		JOIN tblMFWorkOrderStatus ws ON w.intStatusId = ws.intStatusId
		JOIN tblMFManufacturingCell mc ON w.intManufacturingCellId = mc.intManufacturingCellId
		LEFT JOIN tblSMUserSecurity us ON w.intCreatedUserId = us.[intEntityId]
		LEFT JOIN tblICStorageLocation sl ON w.intStorageLocationId = sl.intStorageLocationId
		WHERE ISNULL(w.intBlendRequirementId, 0) > 0
			AND w.intStatusId = 13
			AND w.intLocationId = @intLocationId
		ORDER BY w.dtmCompletedDate DESC
END
