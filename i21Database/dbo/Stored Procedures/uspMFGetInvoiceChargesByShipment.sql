CREATE PROCEDURE [dbo].[uspMFGetInvoiceChargesByShipment]
	@intInventoryShipmentItemId int
AS

Declare @intItemId INT
Declare @dblRecipeQty NUMERIC(38,20)
Declare @intRecipeId INT
Declare @intLocationId INT
Declare @intSalesOrderId INT
Declare @dblShipQty NUMERIC(38,20)

Declare @tblInputItem AS TABLE
(
	intItemId INT,
	dblUnitCost NUMERIC(38,20),
	dblLineTotal NUMERIC(38,20)
)

Select @intItemId=intItemId,@intSalesOrderId=intLineNo,@dblShipQty=dbo.fnICConvertUOMtoStockUnit(@intItemId,intItemUOMId,dblQuantity)
From tblICInventoryShipmentItem Where intInventoryShipmentItemId=@intInventoryShipmentItemId
Select @intLocationId=intCompanyLocationId From tblSOSalesOrder Where intSalesOrderId=@intSalesOrderId
Select TOP 1 @intRecipeId=r.intRecipeId,@dblRecipeQty=dblQuantity From tblMFRecipe r where r.intItemId=@intItemId AND r.ysnActive=1

INSERT INTO @tblInputItem(intItemId,dblUnitCost,dblLineTotal)
Select t.intItemId,t.dblUnitCost,(t.dblUnitCost * @dblShipQty) AS dblLineTotal From
(Select ri.intItemId,(CASE WHEN ri.intMarginById=1 THEN  ri.dblMargin + (ri.dblMargin * ISNULL(ip.dblStandardCost,0))/100 
ELSE ISNULL(ip.dblStandardCost,0) + ri.dblMargin End)/@dblRecipeQty AS dblUnitCost
From tblMFRecipeItem ri 
Join tblICItem i on ri.intItemId=i.intItemId
Join tblICItemLocation il on i.intItemId=il.intItemId AND il.intLocationId=1
Left Join tblICItemPricing ip on i.intItemId=ip.intItemId AND il.intItemLocationId=ip.intItemLocationId
where ri.intRecipeId=@intRecipeId AND i.strType='Other Charge' AND ISNULL(ri.dblMargin,0)>0 
AND ISNULL(ri.ysnCostAppliedAtInvoice,0)=1) t

Select * from @tblInputItem
