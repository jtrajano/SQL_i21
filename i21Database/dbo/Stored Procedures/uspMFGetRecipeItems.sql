CREATE PROCEDURE [dbo].[uspMFGetRecipeItems]
	@intRecipeId int,
	@intLocationId int,
	@dblQuantity NUMERIC(38,20),
	@intCostTypeId int,
	@intMarginById int,
	@dblMargin NUMERIC(38,20),
	@intSalesOrderId int=null
AS
Declare @dblRecipeQty NUMERIC(38,20)
Declare @dblQty NUMERIC(38,20)
Declare @dblUnitMargin NUMERIC(38,20)
Declare @dblTotalCost NUMERIC(38,20)
Declare @tblRecipeItemCostWithMargin AS table
(
	intRecipeItemId int,
	dblQuantity NUMERIC(38,20),
	dblCost NUMERIC(38,20),
	dblCostWithMargin NUMERIC(38,20),
	dblUnitMargin NUMERIC(38,20)
)
 
Select @dblRecipeQty=dblQuantity From tblMFRecipe Where intRecipeId=@intRecipeId

If ISNULL(@intCostTypeId,0)=0
	Set @intCostTypeId=1

If ISNULL(@intMarginById,0)=0
	Set @intMarginById=2

if ISNULL(@dblMargin,0)=0
	Set @dblMargin=0

if @dblMargin>0
Begin
	Set @dblMargin=@dblMargin * (@dblQuantity/@dblRecipeQty)

	--only use the items where cost > 0
	Insert Into @tblRecipeItemCostWithMargin(intRecipeItemId,dblQuantity,dblCost)
	Select ri.intRecipeItemId,(ri.dblCalculatedQuantity * (@dblQuantity/r.dblQuantity)) AS dblQuantity,
	ISNULL(dbo.fnMFConvertCostToTargetItemUOM((Select intItemUOMId From tblICItemUOM Where intItemId=ri.intItemId AND ysnStockUnit=1),ri.intItemUOMId,
	CASE When @intCostTypeId=2 AND ISNULL(ip.dblAverageCost,0) > 0 THEN ISNULL(ip.dblAverageCost,0) 
	When @intCostTypeId=3 AND ISNULL(ip.dblLastCost,0) > 0 THEN ISNULL(ip.dblLastCost,0)
	Else ISNULL(ip.dblStandardCost,0) End
	),0) AS dblCost
	From tblMFRecipeItem ri Join tblICItem i on ri.intItemId=i.intItemId 
	Join tblICItemUOM iu on ri.intItemUOMId=iu.intItemUOMId --AND iu.ysnStockUnit=1
	Join tblICUnitMeasure um on iu.intUnitMeasureId=um.intUnitMeasureId
	Left Join tblMFMarginBy mg on ri.intMarginById=mg.intMarginById
	Join tblICItemLocation il on ri.intItemId=il.intItemId AND il.intLocationId=@intLocationId 
	Left Join tblICItemPricing ip on ip.intItemId=ri.intItemId AND ip.intItemLocationId=il.intItemLocationId
	Join tblMFRecipe r on ri.intRecipeId=r.intRecipeId
	Where ri.intRecipeId=@intRecipeId AND ri.intRecipeItemTypeId=1 AND ri.intConsumptionMethodId in (1,2,3)
	AND ISNULL(CASE When @intCostTypeId=2 AND ISNULL(ip.dblAverageCost,0) > 0 THEN ISNULL(ip.dblAverageCost,0) 
	When @intCostTypeId=3 AND ISNULL(ip.dblLastCost,0) > 0 THEN ISNULL(ip.dblLastCost,0)
	Else ISNULL(ip.dblStandardCost,0) End,0)>0

	Select @dblQty=SUM(dblQuantity) From @tblRecipeItemCostWithMargin

	if @intMarginById = 2
	Begin
		Select @dblUnitMargin=@dblMargin/@dblQty

		Update @tblRecipeItemCostWithMargin Set dblCostWithMargin=dblCost + @dblUnitMargin,dblUnitMargin=@dblUnitMargin
	End
	Else
	Begin
		Select @dblTotalCost= SUM(dblQuantity * dblCost) From @tblRecipeItemCostWithMargin

		Select @dblUnitMargin=((@dblTotalCost * @dblMargin)/100)/@dblQty

		Update @tblRecipeItemCostWithMargin Set dblCostWithMargin=dblCost + @dblUnitMargin,dblUnitMargin=@dblUnitMargin
	End
End

Select *,t.dblCost AS dblCostCopy FROM
(
Select ri.intRecipeId,ri.intRecipeItemId,ri.intItemId,i.strItemNo,i.strDescription AS strItemDescription,i.strType AS strItemType,
ri.dblCalculatedQuantity * (@dblQuantity/@dblRecipeQty) AS dblQuantity,
ri.dblCalculatedQuantity,
ri.intItemUOMId,um.strUnitMeasure AS strUOM,ri.intMarginById,mg.strName AS strMarginBy,ISNULL(ri.dblMargin,0) AS dblMargin,
CASE WHEN ISNULL(sd.intContractDetailId,0)=0 THEN
CASE When @dblMargin = 0 Then
ISNULL(dbo.fnMFConvertCostToTargetItemUOM((Select intItemUOMId From tblICItemUOM Where intItemId=ri.intItemId AND ysnStockUnit=1),ri.intItemUOMId,
CASE When @intCostTypeId=2 AND ISNULL(ip.dblAverageCost,0) > 0 THEN ISNULL(ip.dblAverageCost,0) 
When @intCostTypeId=3 AND ISNULL(ip.dblLastCost,0) > 0 THEN ISNULL(ip.dblLastCost,0)
Else ISNULL(ip.dblStandardCost,0) End
),0) 
Else
cm.dblCostWithMargin End
ELSE sd.dblPrice End
AS dblCost,
CASE WHEN ISNULL(sd.intContractDetailId,0)=0 THEN 1 ELSE 2 END AS intCostSourceId,
CASE WHEN ISNULL(sd.intContractDetailId,0)=0 THEN 'Item' ELSE 'Sales Contract' END AS strCostSource,
0.0 AS dblRetailPrice,
iu.dblUnitQty,
ri.dblCalculatedLowerTolerance * (@dblQuantity/@dblRecipeQty) AS dblCalculatedLowerTolerance,
ri.dblCalculatedUpperTolerance * (@dblQuantity/@dblRecipeQty) AS dblCalculatedUpperTolerance,
ri.dblLowerTolerance,ri.dblUpperTolerance,
0 intCommentTypeId,'' strCommentType,
sd.intContractHeaderId,sd.intContractDetailId,cv.strContractNumber,cv.intContractSeq,cv.strSequenceNumber,
ISNULL(dbo.fnMFConvertCostToTargetItemUOM((Select intItemUOMId From tblICItemUOM Where intItemId=ri.intItemId AND ysnStockUnit=1),ri.intItemUOMId,
ISNULL(ip.dblStandardCost,0.0)
),0) AS dblStandardCost, 
ISNULL(cm.dblUnitMargin,0.0) AS dblUnitMargin
From tblMFRecipeItem ri Join tblICItem i on ri.intItemId=i.intItemId 
Join tblICItemUOM iu on ri.intItemUOMId=iu.intItemUOMId --AND iu.ysnStockUnit=1
Join tblICUnitMeasure um on iu.intUnitMeasureId=um.intUnitMeasureId
Left Join tblMFMarginBy mg on ri.intMarginById=mg.intMarginById
Join tblICItemLocation il on ri.intItemId=il.intItemId AND il.intLocationId=@intLocationId 
Left Join tblICItemPricing ip on ip.intItemId=ri.intItemId AND ip.intItemLocationId=il.intItemLocationId
Left Join @tblRecipeItemCostWithMargin cm on ri.intRecipeItemId=cm.intRecipeItemId
Left Join tblSOSalesOrderDetail sd on sd.intRecipeItemId=ri.intRecipeItemId AND sd.intRecipeId=@intRecipeId AND sd.intSalesOrderId=@intSalesOrderId
Left Join vyuCTContractDetailView cv on sd.intContractDetailId=cv.intContractDetailId
Where ri.intRecipeId=@intRecipeId AND ri.intRecipeItemTypeId=1 AND i.strType <> 'Other Charge'
UNION
Select ri.intRecipeId,ri.intRecipeItemId,ri.intItemId,i.strItemNo,CASE WHEN ISNULL(sd.strItemDescription,'')='' THEN ri.strDescription Else sd.strItemDescription End AS strItemDescription,
i.strType AS strItemType,0 dblQuantity,0 dblCalculatedQuantity,
0 intItemUOMId,'' strUOM,0 intMarginById,'' strMarginBy,0 AS dblMargin,
0 AS dblCost,0 AS intCostSourceId,'' AS strCostSource,0.0 AS dblRetailPrice,
0 dblUnitQty,0 dblCalculatedLowerTolerance,0 dblCalculatedUpperTolerance,0 dblLowerTolerance,0 dblUpperTolerance,
ri.intCommentTypeId,ct.strName strCommentType,
null intContractHeaderId,null intContractDetailId,null strContractNumber,null intContractSeq,null strSequenceNumber,0.0 AS dblStandardCost,0.0 AS dblUnitMargin
From tblMFRecipeItem ri Join tblICItem i on ri.intItemId=i.intItemId 
Join tblMFCommentType ct on ri.intCommentTypeId=ct.intCommentTypeId
Left Join tblSOSalesOrderDetail sd on sd.intRecipeItemId=ri.intRecipeItemId AND sd.intRecipeId=@intRecipeId AND sd.intSalesOrderId=@intSalesOrderId
Where ri.intRecipeId=@intRecipeId
) t