CREATE PROCEDURE [dbo].[uspMFGetBlendRequests]
	@intWorkOrderId int = 0
AS
SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

If @intWorkOrderId=0
	Select a.intBlendRequirementId,a.strDemandNo,a.intItemId,b.strItemNo,b.strDescription,(a.dblQuantity - ISNULL(a.dblIssuedQty,0)) dblQuantity,
	c.intItemUOMId,d.strUnitMeasure AS strUOM,a.dtmDueDate,a.intLocationId,
	a.intManufacturingCellId AS intManufacturingCellId,
	a.intMachineId,a.dblBlenderSize,g.dblStandardCost,mc.strCellName 
	from tblMFBlendRequirement a 
	Join tblICItem b on a.intItemId=b.intItemId 
	Join tblICItemUOM c on b.intItemId=c.intItemId and a.intUOMId=c.intUnitMeasureId 
	Join tblICUnitMeasure d on c.intUnitMeasureId=d.intUnitMeasureId 
	Left Join tblMFRecipe e on a.intItemId=e.intItemId And a.intLocationId=e.intLocationId And e.ysnActive=1 
	Left Join tblICItemLocation f on b.intItemId=f.intItemId and f.intLocationId=a.intLocationId
	Left Join tblICItemPricing g on g.intItemId=b.intItemId And g.intItemLocationId=f.intItemLocationId
	Left Join tblMFManufacturingCell mc on a.intManufacturingCellId=mc.intManufacturingCellId
	Where a.intStatusId=1

--Positive means WorkOrderId
If @intWorkOrderId>0
	Select a.intBlendRequirementId,a.strDemandNo,a.intItemId,b.strItemNo,b.strDescription,
	Case When (a.dblQuantity - ISNULL(a.dblIssuedQty,0))<=0 then 0 Else (a.dblQuantity - ISNULL(a.dblIssuedQty,0)) End AS dblQuantity,
	c.intItemUOMId,d.strUnitMeasure AS strUOM,a.dtmDueDate,a.intLocationId,a.intManufacturingCellId,
	h.dblStandardCost  
	from tblMFBlendRequirement a 
	Join tblICItem b on a.intItemId=b.intItemId 
	Join tblICItemUOM c on b.intItemId=c.intItemId and a.intUOMId=c.intUnitMeasureId 
	Join tblICUnitMeasure d on c.intUnitMeasureId=d.intUnitMeasureId 
	Left Join tblMFRecipe e on a.intItemId=e.intItemId And a.intLocationId=e.intLocationId And e.ysnActive=1 
	Join tblMFWorkOrder f on a.intBlendRequirementId=f.intBlendRequirementId
	Left Join tblICItemLocation g on b.intItemId=g.intItemId and g.intLocationId=a.intLocationId
	Left Join tblICItemPricing h on h.intItemId=b.intItemId And g.intItemLocationId=h.intItemLocationId
	Where f.intWorkOrderId=@intWorkOrderId

--Negative means BlendRequirementId
If @intWorkOrderId<0
	Select a.intBlendRequirementId,a.strDemandNo,a.intItemId,b.strItemNo,b.strDescription,
	Case When (a.dblQuantity - ISNULL(a.dblIssuedQty,0))<=0 then 0 Else (a.dblQuantity - ISNULL(a.dblIssuedQty,0)) End AS dblQuantity,
	c.intItemUOMId,d.strUnitMeasure AS strUOM,a.dtmDueDate,a.intLocationId,a.intManufacturingCellId,
	h.dblStandardCost  
	from tblMFBlendRequirement a 
	Join tblICItem b on a.intItemId=b.intItemId 
	Join tblICItemUOM c on b.intItemId=c.intItemId and a.intUOMId=c.intUnitMeasureId 
	Join tblICUnitMeasure d on c.intUnitMeasureId=d.intUnitMeasureId 
	Left Join tblMFRecipe e on a.intItemId=e.intItemId And a.intLocationId=e.intLocationId And e.ysnActive=1 
	Left Join tblICItemLocation g on b.intItemId=g.intItemId and g.intLocationId=a.intLocationId
	Left Join tblICItemPricing h on h.intItemId=b.intItemId And g.intItemLocationId=h.intItemLocationId
	Where a.intBlendRequirementId=ABS(@intWorkOrderId)