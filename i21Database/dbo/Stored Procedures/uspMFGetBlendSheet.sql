CREATE PROCEDURE [dbo].[uspMFGetBlendSheet]
	@intWorkOrderId int
AS
Select a.intWorkOrderId,a.strWorkOrderNo,a.intItemId,b.strItemNo,a.dblQuantity,
a.dblPlannedQuantity,a.intItemUOMId,d.strUnitMeasure AS strUOM,a.intStatusId,a.intManufacturingCellId,a.intMachineId,
a.dtmCreated,a.intCreatedUserId,a.dtmLastModified,a.intLastModifiedUserId,a.dtmExpectedDate,
a.dblBinSize,a.intBlendRequirementId,a.ysnUseTemplate,
a.ysnKittingEnabled,a.strComment,a.intLocationId, 
Case When (e.dblQuantity - ISNULL(e.dblIssuedQty ,0)) <=0 Then a.dblQuantity Else (e.dblQuantity - ISNULL(e.dblIssuedQty ,0)) End AS dblBalancedQtyToProduce,
mc.strCellName,m.strName AS strMachineName
From tblMFWorkOrder a Join tblICItem b on a.intItemId=b.intItemId
Join tblICItemUOM c on a.intItemUOMId=c.intItemUOMId
Join tblICUnitMeasure d on c.intUnitMeasureId=d.intUnitMeasureId
Join tblMFBlendRequirement e on a.intBlendRequirementId=e.intBlendRequirementId
Left Join tblMFManufacturingCell mc on a.intManufacturingCellId=mc.intManufacturingCellId
Left Join tblMFMachine m on a.intMachineId=m.intMachineId
Where a.intWorkOrderId=@intWorkOrderId
