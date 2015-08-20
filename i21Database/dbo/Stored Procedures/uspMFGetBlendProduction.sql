CREATE PROCEDURE [dbo].[uspMFGetBlendProduction]
@intWorkOrderId int
AS
SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

DECLARE @dblConfirmedQty numeric(18,6)

Select @dblConfirmedQty=ISNULL(sum(dblQuantity),0.0) From tblMFWorkOrderConsumedLot Where intWorkOrderId=@intWorkOrderId AND ISNULL(ysnStaged,0)=1

Select w.intWorkOrderId,w.strWorkOrderNo,i.intItemId,i.strItemNo,i.strDescription,w.dblQuantity,
w.dblPlannedQuantity,w.intItemUOMId,um.strUnitMeasure AS strUOM,w.intStatusId,w.intManufacturingCellId,w.intMachineId,
w.dtmCreated,w.intCreatedUserId,w.dtmLastModified,w.intLastModifiedUserId,w.dtmExpectedDate,
w.dblBinSize,w.intBlendRequirementId,
w.ysnKittingEnabled,w.strComment,w.intLocationId,w.intStorageLocationId,
br.strDemandNo,ISNULL(ws.strBackColorName,'') AS strBackColorName,us.strUserName,w.intExecutionOrder,
ws.strName AS strStatus,sl.strName AS strStorageLocation,
@dblConfirmedQty AS dblConfirmedQty
From tblMFWorkOrder w Join tblICItem i on w.intItemId=i.intItemId
Join tblICItemUOM iu on w.intItemUOMId=iu.intItemUOMId
Join tblICUnitMeasure um on iu.intUnitMeasureId=um.intUnitMeasureId
Join tblMFBlendRequirement br on w.intBlendRequirementId=br.intBlendRequirementId
Join tblMFWorkOrderStatus ws on w.intStatusId=ws.intStatusId
Left Join tblSMUserSecurity us on w.intCreatedUserId=us.intUserSecurityID
Left Join tblICStorageLocation sl on w.intStorageLocationId=sl.intStorageLocationId
Where w.intWorkOrderId=@intWorkOrderId AND w.intStatusId in (9,10,11,12) 
Order By w.dtmExpectedDate,w.intExecutionOrder