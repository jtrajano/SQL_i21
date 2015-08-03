CREATE PROCEDURE [dbo].[uspMFGetBlendSheet]
	@intWorkOrderId int
AS
Select a.intWorkOrderId,a.strWorkOrderNo,a.intItemId,b.strItemNo,a.dblQuantity,
a.dblPlannedQuantity,a.intItemUOMId,d.strUnitMeasure AS strUOM,a.intStatusId,a.intManufacturingCellId,a.intMachineId,
a.dtmCreated,a.intCreatedUserId,a.dtmLastModified,a.intLastModifiedUserId,a.dtmExpectedDate,
a.dblBinSize,a.intBlendRequirementId,a.ysnUseTemplate,
a.ysnKittingEnabled,a.strComment,a.intLocationId, 
Case When (e.dblQuantity - ISNULL(e.dblIssuedQty ,0)) <=0 Then a.dblQuantity Else (e.dblQuantity - ISNULL(e.dblIssuedQty ,0)) End AS dblBalancedQtyToProduce
From tblMFWorkOrder a Join tblICItem b on a.intItemId=b.intItemId
Join tblICItemUOM c on b.intItemId=c.intItemId
Join tblICUnitMeasure d on c.intUnitMeasureId=d.intUnitMeasureId
Join tblMFBlendRequirement e on a.intBlendRequirementId=e.intBlendRequirementId
Where a.intWorkOrderId=@intWorkOrderId
