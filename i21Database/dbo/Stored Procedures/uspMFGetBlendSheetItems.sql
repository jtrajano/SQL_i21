CREATE PROCEDURE [dbo].[uspMFGetBlendSheetItems]
	@intItemId int,
	@intLocationId int,
	@dblQtyToProduce decimal(38,20),
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
	dblRequiredQty numeric(38,20),
	ysnIsSubstitute bit,
	intParentItemId int,
	ysnHasSubstitute bit,
	intRecipeItemId int,
	intParentRecipeItemId int,
	strGroupName nVarchar(50),
	dblLowerToleranceQty numeric(38,20),
	dblUpperToleranceQty numeric(38,20),
	ysnMinorIngredient bit,
	ysnScaled bit,
	dblRecipeQty numeric(38,20),
	dblRecipeItemQty numeric(38,20),
	strRecipeItemUOM nvarchar(50),
	strConsumptionStorageLocation nvarchar(50),
	intConsumptionMethodId int
)

Insert into @tblRequiredQty
--Select ri.intItemId,case when ri.ysnScaled=1 then (ri.dblCalculatedQuantity * (@dblQtyToProduce/r.dblQuantity)) else ri.dblCalculatedQuantity end AS RequiredQty
Select ri.intItemId,(ri.dblCalculatedQuantity * (@dblQtyToProduce/r.dblQuantity)) RequiredQty,0,0,0,ri.intRecipeItemId,0,ri.strItemGroupName,
(ri.dblCalculatedLowerTolerance * (@dblQtyToProduce/r.dblQuantity)) AS dblLowerToleranceQty,
(ri.dblCalculatedUpperTolerance * (@dblQtyToProduce/r.dblQuantity)) AS dblUpperToleranceQty,
ri.ysnMinorIngredient,ysnScaled,r.dblQuantity AS dblRecipeQty,
ri.dblQuantity AS dblRecipeItemQty,u.strUnitMeasure AS strRecipeItemUOM,
ISNULL(sl.strName,'') AS strConsumptionStorageLocation,ri.intConsumptionMethodId
From tblMFRecipeItem ri 
Join tblMFRecipe r on r.intRecipeId=ri.intRecipeId 
Join tblICItemUOM iu on ri.intItemUOMId=iu.intItemUOMId
Join tblICUnitMeasure u on iu.intUnitMeasureId=u.intUnitMeasureId
Left Join tblICStorageLocation sl on ri.intStorageLocationId=sl.intStorageLocationId
Join tblICItem i on ri.intItemId=i.intItemId AND i.strType <> 'Other Charge'
where r.intRecipeId=@intRecipeId and ri.intRecipeItemTypeId=1 and
((ri.ysnYearValidationRequired = 1 AND @dtmDate BETWEEN ri.dtmValidFrom AND ri.dtmValidTo)
OR (ri.ysnYearValidationRequired = 0 AND @intDayOfYear BETWEEN DATEPART(dy, ri.dtmValidFrom) AND DATEPART(dy, ri.dtmValidTo)))
Union
Select rs.intSubstituteItemId AS intItemId,(rs.dblQuantity * (@dblQtyToProduce/r.dblQuantity)) RequiredQty,1,rs.intItemId,0,rs.intRecipeSubstituteItemId,rs.intRecipeItemId,'',
(rs.dblCalculatedLowerTolerance * (@dblQtyToProduce/r.dblQuantity)) AS dblLowerToleranceQty,
(rs.dblCalculatedUpperTolerance * (@dblQtyToProduce/r.dblQuantity)) AS dblUpperToleranceQty,
0 AS ysnMinorIngredient,0 AS ysnScaled,r.dblQuantity AS dblRecipeQty,
rs.dblQuantity AS dblRecipeItemQty,u.strUnitMeasure AS strRecipeItemUOM,
'' AS strConsumptionStorageLocation,0
From tblMFRecipeSubstituteItem rs
Join tblMFRecipe r on r.intRecipeId=rs.intRecipeId 
Join tblICItemUOM iu on rs.intItemUOMId=iu.intItemUOMId
Join tblICUnitMeasure u on iu.intUnitMeasureId=u.intUnitMeasureId
where r.intRecipeId=@intRecipeId and rs.intRecipeItemTypeId=1

Update a Set a.ysnHasSubstitute=1 from @tblRequiredQty a Join @tblRequiredQty b on a.intItemId=b.intParentItemId

Declare @tblPhysicalQty table
(
	intItemId int,
	dblPhysicalQty numeric(38,20),
	dblWeightPerUnit numeric(38,20)
)

Insert into @tblPhysicalQty
Select ri.intItemId,Sum(l.dblWeight) AS dblPhysicalQty,
CASE When  ISNULL(MAX(l.dblWeightPerQty),1)=0 then 1 Else  ISNULL(MAX(l.dblWeightPerQty),1) End AS dblWeightPerUnit
From tblICLot l 
Join tblMFRecipeItem ri on ri.intItemId=l.intItemId 
Join tblICItem i on ri.intItemId=i.intItemId AND i.strType <> 'Other Charge'
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
	dblReservedQty numeric(38,20)
)

Insert into @tblReservedQty
Select ri.intItemId,Sum(sr.dblQty) AS dblReservedQty 
From tblICStockReservation sr 
Join tblMFRecipeItem ri on ri.intItemId=sr.intItemId 
Join tblICItem i on ri.intItemId=i.intItemId AND i.strType <> 'Other Charge'
where ri.intRecipeId=@intRecipeId and ri.intRecipeItemTypeId=1 AND ISNULL(sr.ysnPosted,0)=0
group by ri.intItemId

--Substitute
Insert into @tblReservedQty
Select rs.intSubstituteItemId,Sum(sr.dblQty) AS dblReservedQty 
From tblICStockReservation sr 
Join tblMFRecipeSubstituteItem rs on rs.intSubstituteItemId=sr.intItemId 
where rs.intRecipeId=@intRecipeId AND ISNULL(sr.ysnPosted,0)=0
group by rs.intSubstituteItemId

Select i.intItemId,i.strItemNo,i.strDescription,a.dblRequiredQty,ISNULL(b.dblPhysicalQty,0) AS dblPhysicalQty,
ISNULL(c.dblReservedQty,0) AS dblReservedQty, ISNULL((ISNULL(b.dblPhysicalQty,0) - ISNULL(c.dblReservedQty,0)),0) AS dblAvailableQty,
0.0 AS dblSelectedQty,
ISNULL(ROUND((ISNULL((ISNULL(b.dblPhysicalQty,0) - ISNULL(c.dblReservedQty,0)),0))/ CASE WHEN ISNULL(b.dblWeightPerUnit,1)=0 THEN 1 ELSE ISNULL(b.dblWeightPerUnit,1) END,0),0.0) AS dblAvailableUnit,
a.ysnIsSubstitute,a.intParentItemId,a.ysnHasSubstitute,a.intRecipeItemId,a.intParentRecipeItemId,a.strGroupName,
a.dblLowerToleranceQty,a.dblUpperToleranceQty,
a.ysnMinorIngredient,a.ysnScaled,a.dblRecipeQty,
a.dblRecipeItemQty,a.strRecipeItemUOM,a.strConsumptionStorageLocation,a.intConsumptionMethodId
from @tblRequiredQty a 
Left Join @tblPhysicalQty b on a.intItemId=b.intItemId
Left Join @tblReservedQty c on a.intItemId=c.intItemId
Join tblICItem i on a.intItemId=i.intItemId

