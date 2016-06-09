CREATE PROCEDURE [dbo].[uspMFGetInvoiceChargesByShipment]
	@intInventoryShipmentItemId int,
	@intSalesOrderId int
AS

Declare @intItemId INT
Declare @dblRecipeQty NUMERIC(38,20)
Declare @intRecipeId INT
Declare @intLocationId INT
Declare @dblShipQty NUMERIC(38,20)
Declare @intSalesOrderDetailId INT

Declare @tblInputItem AS TABLE
(
	intItemId INT,
	dblPrice NUMERIC(38,20),
	dblLineTotal NUMERIC(38,20)
)

Declare @tblRecipe AS TABLE
(
	intRecipeId INT,
	dblShipQty NUMERIC(38,20)
)

If ISNULL(@intInventoryShipmentItemId,0)>0 --Shipment Created before invoice
Begin
	Select @intSalesOrderDetailId=intLineNo From tblICInventoryShipmentItem si Join tblICInventoryShipment sh on si.intInventoryShipmentId=sh.intInventoryShipmentId 
	Where intInventoryShipmentItemId=@intInventoryShipmentItemId AND sh.intOrderType=2

	Select @intRecipeId=intRecipeId,@intSalesOrderId=intSalesOrderId From tblSOSalesOrderDetail Where intSalesOrderDetailId=@intSalesOrderDetailId

	Select @intLocationId=intCompanyLocationId From tblSOSalesOrder Where intSalesOrderId=@intSalesOrderId

	If ISNULL(@intRecipeId,0)>0 --Recipe Added to SO
	Begin
		Select @dblRecipeQty=dblQuantity From tblMFRecipe Where intRecipeId=@intRecipeId

		Select @dblShipQty=SUM(dbo.fnICConvertUOMtoStockUnit(intItemId,intItemUOMId,dblQuantity))
		From tblICInventoryShipmentItem Where intOrderId=@intSalesOrderId AND intLineNo 
		IN (Select intSalesOrderDetailId From tblSOSalesOrderDetail Where intSalesOrderId=@intSalesOrderId AND intRecipeId=@intRecipeId)
	End
	Else
	Begin --Blend/FG Recipe
		Select @intItemId=intItemId,@dblShipQty=dbo.fnICConvertUOMtoStockUnit(@intItemId,intItemUOMId,dblQuantity)
		From tblICInventoryShipmentItem Where intInventoryShipmentItemId=@intInventoryShipmentItemId

		Select TOP 1 @intRecipeId=r.intRecipeId,@dblRecipeQty=dblQuantity From tblMFRecipe r where r.intItemId=@intItemId AND r.ysnActive=1
	End

		INSERT INTO @tblInputItem(intItemId,dblPrice,dblLineTotal)
		Select t.intItemId,t.dblPrice,(t.dblPrice * @dblShipQty) AS dblLineTotal From
		(Select ri.intItemId,(CASE WHEN ri.intMarginById=1 THEN  ri.dblMargin + (ri.dblMargin * ISNULL(ip.dblStandardCost,0))/100 
		ELSE ISNULL(ip.dblStandardCost,0) + ri.dblMargin End)/@dblRecipeQty AS dblPrice
		From tblMFRecipeItem ri 
		Join tblICItem i on ri.intItemId=i.intItemId
		Join tblICItemLocation il on i.intItemId=il.intItemId AND il.intLocationId=1
		Left Join tblICItemPricing ip on i.intItemId=ip.intItemId AND il.intItemLocationId=ip.intItemLocationId
		where ri.intRecipeId=@intRecipeId AND i.strType='Other Charge' AND ISNULL(ri.dblMargin,0)>0 
		AND ISNULL(ri.ysnCostAppliedAtInvoice,0)=1) t
End
Else
Begin --No Shipment created before invoice
	
	--Distinct Recipe
	INSERT @tblRecipe(intRecipeId,dblShipQty)
	Select intRecipeId,SUM(dbo.fnICConvertUOMtoStockUnit(intItemId,intItemUOMId,dblQtyOrdered)) 
	From tblSOSalesOrderDetail 
	Where intSalesOrderId=@intSalesOrderId AND ISNULL(intRecipeId,0)>0 Group By intRecipeId

	--Blend/FG
	INSERT @tblRecipe(intRecipeId,dblShipQty)
	Select r.intRecipeId,dbo.fnICConvertUOMtoStockUnit(sd.intItemId,sd.intItemUOMId,sd.dblQtyOrdered)
	From tblSOSalesOrderDetail sd Join tblICItem i on sd.intItemId=i.intItemId 
	Join tblMFRecipe r on i.intItemId=r.intItemId AND r.ysnActive=1
	Where intSalesOrderId=@intSalesOrderId AND ISNULL(sd.intRecipeId,0)=0 AND i.strType='Finished Good'

	--Get Other Charges
	INSERT INTO @tblInputItem(intItemId,dblPrice,dblLineTotal)
	Select t.intItemId,t.dblPrice,(t.dblPrice * t.dblShipQty) AS dblLineTotal From
	(Select ri.intItemId,(CASE WHEN ri.intMarginById=1 THEN  ri.dblMargin + (ri.dblMargin * ISNULL(ip.dblStandardCost,0))/100 
	ELSE ISNULL(ip.dblStandardCost,0) + ri.dblMargin End)/r.dblQuantity AS dblPrice,tr.dblShipQty
	From tblMFRecipeItem ri 
	Join tblICItem i on ri.intItemId=i.intItemId
	Join tblICItemLocation il on i.intItemId=il.intItemId AND il.intLocationId=1
	Left Join tblICItemPricing ip on i.intItemId=ip.intItemId AND il.intItemLocationId=ip.intItemLocationId
	Join @tblRecipe tr on ri.intRecipeId=tr.intRecipeId
	Join tblMFRecipe r on tr.intRecipeId=r.intRecipeId
	where i.strType='Other Charge' AND ISNULL(ri.dblMargin,0)>0 
	AND ISNULL(ri.ysnCostAppliedAtInvoice,0)=1) t
End

Select i.intItemId,i.strItemNo,i.strDescription,ti.dblPrice,ti.dblLineTotal 
From @tblInputItem ti Join tblICItem i on ti.intItemId=i.intItemId