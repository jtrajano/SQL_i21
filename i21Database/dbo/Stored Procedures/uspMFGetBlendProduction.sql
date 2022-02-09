CREATE PROCEDURE [dbo].[uspMFGetBlendProduction] @intWorkOrderId INT
AS
SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

DECLARE @dblConfirmedQty NUMERIC(18, 6)
DECLARE @intDefaultStorageBin INT
DECLARE @intManufacturingProcessId INT
DECLARE @intLocationId INT
DECLARE @dtmExpectedDate DATETIME
DECLARE @dtmProductionDate DATETIME
DECLARE @dtmCurrentDate DATETIME = GETDATE()
DECLARE @dtmBusinessDate DATETIME
DECLARE @intStatusId INT
DECLARE @intShiftId INT
DECLARE @strShiftName NVARCHAR(50)

SELECT @intManufacturingProcessId = intManufacturingProcessId
	,@intLocationId = intLocationId
	,@dtmExpectedDate = dtmExpectedDate
	,@intStatusId = intStatusId
FROM tblMFWorkOrder
WHERE intWorkOrderId = @intWorkOrderId

IF @intStatusId = 12
BEGIN
	SET @dtmProductionDate = @dtmExpectedDate

	IF @dtmProductionDate IS NULL
		OR @dtmProductionDate > GETDATE()
		SET @dtmProductionDate = GETDATE()

	SELECT @dtmBusinessDate = dbo.fnGetBusinessDate(@dtmCurrentDate, @intLocationId)

	SELECT @intShiftId = intShiftId
		,@strShiftName = strShiftName
	FROM dbo.tblMFShift
	WHERE intLocationId = @intLocationId
		AND @dtmCurrentDate BETWEEN @dtmBusinessDate + dtmShiftStartTime + intStartOffset
			AND @dtmBusinessDate + dtmShiftEndTime + intEndOffset
END

SELECT TOP 1 @intDefaultStorageBin = ISNULL(pa.strAttributeValue, 0)
FROM tblMFManufacturingProcessAttribute pa
JOIN tblMFAttribute at ON pa.intAttributeId = at.intAttributeId
WHERE intManufacturingProcessId = @intManufacturingProcessId
	AND intLocationId = @intLocationId
	AND at.strAttributeName = 'Default Storage Bin'

SELECT @dblConfirmedQty = ISNULL(sum(dblQuantity), 0.0)
FROM tblMFWorkOrderConsumedLot
WHERE intWorkOrderId = @intWorkOrderId
	AND ISNULL(ysnStaged, 0) = 1

SELECT w.intWorkOrderId
	,w.strWorkOrderNo
	,i.intItemId
	,i.strItemNo
	,i.strDescription
	,w.dblQuantity
	,w.dblPlannedQuantity
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
	,CASE 
		WHEN ISNULL(w.intStorageLocationId, 0) = 0
			THEN @intDefaultStorageBin
		ELSE w.intStorageLocationId
		END AS intStorageLocationId
	,br.strDemandNo
	,ISNULL(ws.strBackColorName, '') AS strBackColorName
	,us.strUserName
	,w.intExecutionOrder
	,ws.strName AS strStatus
	,sl.strName AS strStorageLocation
	,@dblConfirmedQty AS dblConfirmedQty
	,w.intPickListId
	,pl.strPickListNo
	,i.strLotTracking
	,@dtmProductionDate AS dtmProductionDate
	,@intShiftId AS intShiftId
	,@strShiftName AS strShiftName
	,w.intManufacturingProcessId
	,w.strLotAlias
	,w.strVesselNo
	,w.dblActualQuantity
	,w.dblNoOfUnits
	,w.intNoOfUnitsItemUOMId
	,w.dtmPlannedDate
	,w.intTransactionFrom
	,um1.intUnitMeasureId AS intNoOfUnitsUnitMeasureId
	,um1.strUnitMeasure AS strNoOfUnitsUnitMeasure
	,w.strReferenceNo
	,i.intCategoryId
FROM tblMFWorkOrder w
JOIN tblICItem i ON w.intItemId = i.intItemId
JOIN tblICItemUOM iu ON w.intItemUOMId = iu.intItemUOMId
JOIN tblICUnitMeasure um ON iu.intUnitMeasureId = um.intUnitMeasureId
JOIN tblMFBlendRequirement br ON w.intBlendRequirementId = br.intBlendRequirementId
JOIN tblMFWorkOrderStatus ws ON w.intStatusId = ws.intStatusId
LEFT JOIN tblSMUserSecurity us ON w.intCreatedUserId = us.[intEntityId]
LEFT JOIN tblICStorageLocation sl ON ISNULL(w.intStorageLocationId, @intDefaultStorageBin) = sl.intStorageLocationId
LEFT JOIN tblMFPickList pl ON w.intPickListId = pl.intPickListId
LEFT JOIN tblICItemUOM iu1 ON w.intNoOfUnitsItemUOMId = iu1.intItemUOMId
LEFT JOIN tblICUnitMeasure um1 ON iu1.intUnitMeasureId = um1.intUnitMeasureId
WHERE w.intWorkOrderId = @intWorkOrderId
	AND w.intStatusId IN (
		9
		,10
		,11
		,12
		)
ORDER BY w.dtmExpectedDate
	,w.intExecutionOrder
