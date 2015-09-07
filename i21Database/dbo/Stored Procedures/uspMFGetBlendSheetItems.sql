CREATE PROCEDURE [dbo].[uspMFGetBlendSheetItems]
	@intItemId int,
	@intLocationId int,
	@dblQtyToProduce decimal(18,6),
	@dtmDueDate DateTime
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

Declare @intRecipeId int
Declare @ysnRecipeItemValidityByDueDate bit=0
Declare @intManufacturingProcessId int
Declare @intDayOfYear INT
Declare @dtmDate DATETIME

Select @intRecipeId = intRecipeId,@intManufacturingProcessId=intManufacturingProcessId 
from tblMFRecipe where intItemId=@intItemId and intLocationId=@intLocationId and ysnActive=1

Select @ysnRecipeItemValidityByDueDate=CASE When UPPER(pa.strAttributeValue) = 'TRUE' then 1 Else 0 End 
From tblMFManufacturingProcessAttribute pa Join tblMFAttribute at on pa.intAttributeId=at.intAttributeId
Where intManufacturingProcessId=@intManufacturingProcessId and intLocationId=@intLocationId 
and at.strAttributeName='Recipe Item Validity By Due Date'

If @ysnRecipeItemValidityByDueDate=0
	Set @dtmDate=Convert(date,GetDate())
Else
	Set @dtmDate=Convert(date,@dtmDueDate)

SELECT @intDayOfYear = DATEPART(dy, @dtmDate)

Declare @tblRequiredQty table
(
	intItemId int,
	dblRequiredQty numeric(18,6),
	ysnIsSubstitute bit,
	intParentItemId int,
	ysnHasSubstitute bit,
	intRecipeItemId int,
	intParentRecipeItemId int,
	strGroupName nVarchar(50),
	dblLowerToleranceQty numeric(18,6),
	dblUpperToleranceQty numeric(18,6),
	ysnMinorIngredient bit,
	ysnScaled bit,
	dblRecipeQty numeric(18,6),
	dblRecipeItemQty numeric(18,6),
	strRecipeItemUOM nvarchar(50),
	strConsumptionStorageLocation nvarchar(50)
)

Insert into @tblRequiredQty
--Select ri.intItemId,case when ri.ysnScaled=1 then (ri.dblCalculatedQuantity * (@dblQtyToProduce/r.dblQuantity)) else ri.dblCalculatedQuantity end AS RequiredQty
Select ri.intItemId,(ri.dblCalculatedQuantity * (@dblQtyToProduce/r.dblQuantity)) RequiredQty,0,0,0,ri.intRecipeItemId,0,ri.strItemGroupName,
(ri.dblCalculatedLowerTolerance * (@dblQtyToProduce/r.dblQuantity)) AS dblLowerToleranceQty,
(ri.dblCalculatedUpperTolerance * (@dblQtyToProduce/r.dblQuantity)) AS dblUpperToleranceQty,
ri.ysnMinorIngredient,ysnScaled,r.dblQuantity AS dblRecipeQty,
ri.dblQuantity AS dblRecipeItemQty,u.strUnitMeasure AS strRecipeItemUOM,
ISNULL(sl.strName,'') AS strConsumptionStorageLocation
From tblMFRecipeItem ri 
Join tblMFRecipe r on r.intRecipeId=ri.intRecipeId 
Join tblICUnitMeasure u on ri.intUOMId=u.intUnitMeasureId
Left Join tblICStorageLocation sl on ri.intStorageLocationId=sl.intStorageLocationId
where r.intRecipeId=@intRecipeId and ri.intRecipeItemTypeId=1 and
((ri.ysnYearValidationRequired = 1 AND @dtmDate BETWEEN ri.dtmValidFrom AND ri.dtmValidTo)
OR (ri.ysnYearValidationRequired = 0 AND @intDayOfYear BETWEEN DATEPART(dy, ri.dtmValidFrom) AND DATEPART(dy, ri.dtmValidTo)))
Union
Select rs.intSubstituteItemId AS intItemId,(rs.dblQuantity * (@dblQtyToProduce/r.dblQuantity)) RequiredQty,1,rs.intItemId,0,rs.intRecipeSubstituteItemId,rs.intRecipeItemId,'',
(rs.dblCalculatedLowerTolerance * (@dblQtyToProduce/r.dblQuantity)) AS dblLowerToleranceQty,
(rs.dblCalculatedUpperTolerance * (@dblQtyToProduce/r.dblQuantity)) AS dblUpperToleranceQty,
0 AS ysnMinorIngredient,0 AS ysnScaled,r.dblQuantity AS dblRecipeQty,
rs.dblQuantity AS dblRecipeItemQty,u.strUnitMeasure AS strRecipeItemUOM,
'' AS strConsumptionStorageLocation
From tblMFRecipeSubstituteItem rs
Join tblMFRecipe r on r.intRecipeId=rs.intRecipeId 
Join tblICUnitMeasure u on rs.intUOMId=u.intUnitMeasureId
where r.intRecipeId=@intRecipeId and rs.intRecipeItemTypeId=1

Update a Set a.ysnHasSubstitute=1 from @tblRequiredQty a Join @tblRequiredQty b on a.intItemId=b.intParentItemId

Declare @tblPhysicalQty table
(
	intItemId int,
	dblPhysicalQty numeric(18,6),
	dblWeightPerUnit numeric(38,20)
)

Insert into @tblPhysicalQty
Select ri.intItemId,Sum(l.dblWeight) AS dblPhysicalQty,
CASE When  ISNULL(MAX(l.dblWeightPerQty),1)=0 then 1 Else  ISNULL(MAX(l.dblWeightPerQty),1) End AS dblWeightPerUnit
From tblICLot l 
Join tblMFRecipeItem ri on ri.intItemId=l.intItemId 
where ri.intRecipeId=@intRecipeId and l.intLocationId=@intLocationId
group by ri.intItemId

--Substitute
Insert into @tblPhysicalQty
Select rs.intSubstituteItemId,Sum(l.dblWeight) AS dblPhysicalQty,
CASE When  ISNULL(MAX(l.dblWeightPerQty),1)=0 then 1 Else  ISNULL(MAX(l.dblWeightPerQty),1) End AS dblWeightPerUnit 
From tblICLot l 
Join tblMFRecipeSubstituteItem rs on rs.intSubstituteItemId=l.intItemId 
where rs.intRecipeId=@intRecipeId and l.intLocationId=@intLocationId
group by rs.intSubstituteItemId

Declare @tblReservedQty table
(
	intItemId int,
	dblReservedQty numeric(18,6)
)

--Insert into @tblReservedQty
--Select ri.intItemId,Sum(rd.dblQuantity) AS dblReservedQty 
--From tblICInventoryReservationDetail rd 
--Join tblMFRecipeItem ri on ri.intItemId=rd.intItemId 
--where ri.intRecipeId=@intRecipeId
--group by ri.intItemId

Insert into @tblReservedQty
Select ri.intItemId,Sum(cl.dblQuantity) AS dblReservedQty 
From tblMFWorkOrderConsumedLot cl 
Join tblMFWorkOrder w on cl.intWorkOrderId=w.intWorkOrderId
join tblICLot l on l.intLotId=cl.intLotId
Join tblMFRecipeItem ri on ri.intItemId=l.intItemId 
where ri.intRecipeId=@intRecipeId and w.intStatusId<>13
group by ri.intItemId

--Substitute
Insert into @tblReservedQty
Select rs.intSubstituteItemId,Sum(cl.dblQuantity) AS dblReservedQty 
From tblMFWorkOrderConsumedLot cl 
Join tblMFWorkOrder w on cl.intWorkOrderId=w.intWorkOrderId
join tblICLot l on l.intLotId=cl.intLotId
Join tblMFRecipeSubstituteItem rs on rs.intItemId=l.intItemId 
where rs.intRecipeId=@intRecipeId and w.intStatusId<>13
group by rs.intSubstituteItemId

Select i.intItemId,i.strItemNo,i.strDescription,a.dblRequiredQty,ISNULL(b.dblPhysicalQty,0) AS dblPhysicalQty,
ISNULL(c.dblReservedQty,0) AS dblReservedQty, ISNULL((ISNULL(b.dblPhysicalQty,0) - ISNULL(c.dblReservedQty,0)),0) AS dblAvailableQty,
0.0 AS dblSelectedQty,
ISNULL(ROUND((ISNULL((ISNULL(b.dblPhysicalQty,0) - ISNULL(c.dblReservedQty,0)),0))/ CASE WHEN ISNULL(b.dblWeightPerUnit,1)=0 THEN 1 ELSE ISNULL(b.dblWeightPerUnit,1) END,0),0.0) AS dblAvailableUnit,
a.ysnIsSubstitute,a.intParentItemId,a.ysnHasSubstitute,a.intRecipeItemId,a.intParentRecipeItemId,a.strGroupName,
a.dblLowerToleranceQty,a.dblUpperToleranceQty,
a.ysnMinorIngredient,a.ysnScaled,a.dblRecipeQty,
a.dblRecipeItemQty,a.strRecipeItemUOM,a.strConsumptionStorageLocation
from @tblRequiredQty a 
Left Join @tblPhysicalQty b on a.intItemId=b.intItemId
Left Join @tblReservedQty c on a.intItemId=c.intItemId
Join tblICItem i on a.intItemId=i.intItemId

