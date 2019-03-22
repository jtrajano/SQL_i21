CREATE PROCEDURE [dbo].[uspMFGetBlendProduction]
@intWorkOrderId int
AS
SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

DECLARE @dblConfirmedQty numeric(18,6)
DECLARE @intDefaultStorageBin INT
DECLARE @intManufacturingProcessId INT
DECLARE @intLocationId INT
DECLARE @dtmExpectedDate DateTime
DECLARE @dtmProductionDate DateTime
DECLARE @dtmCurrentDate DateTime=GETDATE()
DECLARE @dtmBusinessDate DateTime
DECLARE @intStatusId INT
DECLARE @intShiftId INT
DECLARE @strShiftName NVARCHAR(50)

Select @intManufacturingProcessId=intManufacturingProcessId,@intLocationId=intLocationId,@dtmExpectedDate=dtmExpectedDate,@intStatusId=intStatusId From tblMFWorkOrder Where intWorkOrderId=@intWorkOrderId

If @intStatusId=12 
Begin
	Set @dtmProductionDate=@dtmExpectedDate
	If @dtmProductionDate is null OR @dtmProductionDate > GETDATE()
		Set @dtmProductionDate=GETDATE()

	SELECT @dtmBusinessDate = dbo.fnGetBusinessDate(@dtmCurrentDate,@intLocationId) 

	SELECT @intShiftId = intShiftId,@strShiftName=strShiftName
	FROM dbo.tblMFShift
	WHERE intLocationId = @intLocationId
		AND @dtmCurrentDate BETWEEN @dtmBusinessDate+dtmShiftStartTime+intStartOffset
					AND @dtmBusinessDate+dtmShiftEndTime + intEndOffset
End

	SELECT TOP 1 @intDefaultStorageBin=ISNULL(pa.strAttributeValue,0)
	FROM tblMFManufacturingProcessAttribute pa
	JOIN tblMFAttribute at ON pa.intAttributeId = at.intAttributeId
	WHERE intManufacturingProcessId = @intManufacturingProcessId
		AND intLocationId = @intLocationId
		AND at.strAttributeName = 'Default Storage Bin'

Select @dblConfirmedQty=ISNULL(sum(dblQuantity),0.0) From tblMFWorkOrderConsumedLot Where intWorkOrderId=@intWorkOrderId AND ISNULL(ysnStaged,0)=1

Select w.intWorkOrderId,w.strWorkOrderNo,i.intItemId,i.strItemNo,i.strDescription,w.dblQuantity,
w.dblPlannedQuantity,w.intItemUOMId,um.strUnitMeasure AS strUOM,w.intStatusId,w.intManufacturingCellId,w.intMachineId,
w.dtmCreated,w.intCreatedUserId,w.dtmLastModified,w.intLastModifiedUserId,w.dtmExpectedDate,
w.dblBinSize,w.intBlendRequirementId,
w.ysnKittingEnabled,w.strComment,w.intLocationId,CASE WHEN ISNULL(w.intStorageLocationId,0)=0 THEN @intDefaultStorageBin ELSE w.intStorageLocationId END AS intStorageLocationId,
br.strDemandNo,ISNULL(ws.strBackColorName,'') AS strBackColorName,us.strUserName,w.intExecutionOrder,
ws.strName AS strStatus,sl.strName AS strStorageLocation,
@dblConfirmedQty AS dblConfirmedQty,w.intPickListId,pl.strPickListNo,i.strLotTracking,@dtmProductionDate AS dtmProductionDate,@intShiftId AS intShiftId,@strShiftName AS strShiftName,w.intManufacturingProcessId
From tblMFWorkOrder w Join tblICItem i on w.intItemId=i.intItemId
Join tblICItemUOM iu on w.intItemUOMId=iu.intItemUOMId
Join tblICUnitMeasure um on iu.intUnitMeasureId=um.intUnitMeasureId
Join tblMFBlendRequirement br on w.intBlendRequirementId=br.intBlendRequirementId
Join tblMFWorkOrderStatus ws on w.intStatusId=ws.intStatusId
Left Join tblSMUserSecurity us on w.intCreatedUserId=us.[intEntityId]
Left Join tblICStorageLocation sl on w.intStorageLocationId=sl.intStorageLocationId
Left Join tblMFPickList pl on w.intPickListId=pl.intPickListId
Where w.intWorkOrderId=@intWorkOrderId AND w.intStatusId in (9,10,11,12) 
Order By w.dtmExpectedDate,w.intExecutionOrder