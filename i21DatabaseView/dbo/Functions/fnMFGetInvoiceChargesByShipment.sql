CREATE FUNCTION [dbo].[fnMFGetInvoiceChargesByShipment]
(
	@intInventoryShipmentItemId int,
	@intSalesOrderId int
)
RETURNS @returntable TABLE
(	
	 [intRecipeItemId]	INT
	,[intItemId]		INT
	,[intItemUOMId]		INT
	,[strItemNo]		NVARCHAR(50)
	,[strDescription]	NVARCHAR(250)
	,[dblQuantity]		NUMERIC(18,6)
	,[dblPrice]		NUMERIC(18,6)
	,[dblLineTotal]	NUMERIC(18,6)	 
)
AS
BEGIN

	Declare @intItemId INT
	Declare @dblRecipeQty NUMERIC(38,20)
	Declare @intRecipeId INT
	Declare @intLocationId INT
	Declare @dblShipQty NUMERIC(38,20)
	Declare @intSalesOrderDetailId INT
	Declare @intItemUOMId INT

	Declare @tblInputItem AS TABLE
	(
		intRecipeItemId INT,
		intItemId INT,
		intItemUOMId INT,
		dblPrice NUMERIC(38,20),
		dblLineTotal NUMERIC(38,20),
		dblQuantity NUMERIC(38,20)
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

			Select @dblShipQty=SUM(dblQuantity)--SUM(dbo.fnICConvertUOMtoStockUnit(intItemId,intItemUOMId,dblQuantity))
			From tblICInventoryShipmentItem Where intOrderId=@intSalesOrderId AND intLineNo 
			IN (Select intSalesOrderDetailId From tblSOSalesOrderDetail Where intSalesOrderId=@intSalesOrderId AND intRecipeId=@intRecipeId)
		End
		Else
		Begin --Blend/FG Recipe
			Select @intItemId=intItemId,@dblShipQty=dblQuantity--dbo.fnICConvertUOMtoStockUnit(@intItemId,intItemUOMId,dblQuantity)
			From tblICInventoryShipmentItem Where intInventoryShipmentItemId=@intInventoryShipmentItemId

			Select TOP 1 @intRecipeId=r.intRecipeId,@dblRecipeQty=dblQuantity From tblMFRecipe r where r.intItemId=@intItemId AND r.ysnActive=1
		End

			Select TOP 1 @intItemUOMId=intItemUOMId From tblMFRecipeItem Where intRecipeId=@intRecipeId AND intRecipeItemTypeId=1 AND intConsumptionMethodId <> 4

			INSERT INTO @tblInputItem(intRecipeItemId,intItemId,intItemUOMId,dblPrice,dblLineTotal,dblQuantity)
			Select t.intRecipeItemId,t.intItemId, t.intItemUOMId, t.dblPrice,(t.dblPrice * (@dblShipQty/@dblRecipeQty)) AS dblLineTotal, @dblShipQty/@dblRecipeQty From
			(Select ri.intRecipeItemId,ri.intItemId, @intItemUOMId AS intItemUOMId,(CASE WHEN ri.intMarginById=1 THEN  ISNULL(ip.dblCost,0) + (ISNULL(ri.dblMargin,0) * ISNULL(ip.dblCost,0))/100 
			ELSE ISNULL(ip.dblCost,0) + ISNULL(ri.dblMargin,0) End) AS dblPrice
			From tblMFRecipeItem ri 
			Join tblICItem i on ri.intItemId=i.intItemId
			Join tblICItemLocation il on i.intItemId=il.intItemId AND il.intLocationId=@intLocationId
			Left Join vyuMFGetItemByLocation ip on i.intItemId=ip.intItemId AND ip.intLocationId=@intLocationId
			where ri.intRecipeId=@intRecipeId AND i.strType='Other Charge'
			AND ISNULL(ri.ysnCostAppliedAtInvoice,0)=1) t
	End
	Else
	Begin --No Shipment created before invoice
		
		Select @intLocationId=intCompanyLocationId From tblSOSalesOrder Where intSalesOrderId=@intSalesOrderId

		--Distinct Recipe
		INSERT @tblRecipe(intRecipeId,dblShipQty)
		Select intRecipeId,SUM(dblQtyOrdered)--SUM(dbo.fnICConvertUOMtoStockUnit(intItemId,intItemUOMId,dblQtyOrdered)) 
		From tblSOSalesOrderDetail 
		Where intSalesOrderId=@intSalesOrderId AND ISNULL(intRecipeId,0)>0 Group By intRecipeId

		--Blend/FG
		INSERT @tblRecipe(intRecipeId,dblShipQty)
		Select r.intRecipeId,dbo.fnICConvertUOMtoStockUnit(sd.intItemId,sd.intItemUOMId,sd.dblQtyOrdered)
		From tblSOSalesOrderDetail sd Join tblICItem i on sd.intItemId=i.intItemId 
		Join tblMFRecipe r on i.intItemId=r.intItemId AND r.ysnActive=1
		Where intSalesOrderId=@intSalesOrderId AND ISNULL(sd.intRecipeId,0)=0 AND i.strType='Finished Good'

		--Get Other Charges
		INSERT INTO @tblInputItem(intRecipeItemId,intItemId,intItemUOMId,dblPrice,dblLineTotal,dblQuantity)
		Select t.intRecipeItemId,t.intItemId,t.intItemUOMId,t.dblPrice,(t.dblPrice * (t.dblShipQty/t.dblRecipeQuantity)) AS dblLineTotal, t.dblShipQty/t.dblRecipeQuantity From
		(Select ri.intRecipeItemId,ri.intItemId, ri.intItemUOMId,(CASE WHEN ri.intMarginById=1 THEN  ISNULL(ip.dblCost,0) + (ISNULL(ri.dblMargin,0) * ISNULL(ip.dblCost,0))/100 
		ELSE ISNULL(ip.dblCost,0) + ISNULL(ri.dblMargin,0) End) AS dblPrice,tr.dblShipQty AS dblShipQty,r.dblQuantity AS dblRecipeQuantity
		From tblMFRecipeItem ri 
		Join tblICItem i on ri.intItemId=i.intItemId
		Join tblICItemLocation il on i.intItemId=il.intItemId AND il.intLocationId=@intLocationId
		Left Join vyuMFGetItemByLocation ip on i.intItemId=ip.intItemId AND ip.intLocationId=@intLocationId
		Join @tblRecipe tr on ri.intRecipeId=tr.intRecipeId
		Join tblMFRecipe r on tr.intRecipeId=r.intRecipeId
		where i.strType='Other Charge' 
		AND ISNULL(ri.ysnCostAppliedAtInvoice,0)=1) t
	End

	Insert Into @returntable(intRecipeItemId,intItemId,intItemUOMId,strItemNo,strDescription,dblQuantity,dblPrice,dblLineTotal)
	Select ti.intRecipeItemId,i.intItemId,ti.intItemUOMId,i.strItemNo,i.strDescription,ti.dblQuantity,ti.dblPrice,ti.dblLineTotal
	From @tblInputItem ti Join tblICItem i on ti.intItemId=i.intItemId

	RETURN				
END
