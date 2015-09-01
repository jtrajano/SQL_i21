CREATE PROCEDURE [dbo].[uspMFGetBlendProductions]
@intManufacturingCellId int
AS
SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

Select w.intWorkOrderId,w.strWorkOrderNo,i.strItemNo,i.strDescription,w.dblQuantity,
w.dblPlannedQuantity,w.intItemUOMId,um.strUnitMeasure AS strUOM,w.intStatusId,w.intManufacturingCellId,w.intMachineId,
w.dtmCreated,w.intCreatedUserId,w.dtmLastModified,w.intLastModifiedUserId,w.dtmExpectedDate,
w.dblBinSize,w.intBlendRequirementId,
w.ysnKittingEnabled,w.strComment,w.intLocationId,w.intStorageLocationId,
br.strDemandNo,ISNULL(ws.strBackColorName,'') AS strBackColorName,us.strUserName,w.intExecutionOrder,
ws.strName AS strStatus,sl.strName AS strStorageLocation,mc.strCellName
From tblMFWorkOrder w Join tblICItem i on w.intItemId=i.intItemId
Join tblICItemUOM iu on w.intItemUOMId=iu.intItemUOMId
Join tblICUnitMeasure um on iu.intUnitMeasureId=um.intUnitMeasureId
Join tblMFBlendRequirement br on w.intBlendRequirementId=br.intBlendRequirementId
Join tblMFWorkOrderStatus ws on w.intStatusId=ws.intStatusId
Join tblMFManufacturingCell mc on w.intManufacturingCellId=mc.intManufacturingCellId
Left Join tblSMUserSecurity us on w.intCreatedUserId=us.intUserSecurityID
Left Join tblICStorageLocation sl on w.intStorageLocationId=sl.intStorageLocationId
Where w.intManufacturingCellId=@intManufacturingCellId AND w.intStatusId in (9,10,11,12) 
Order By w.dtmExpectedDate,w.intExecutionOrder