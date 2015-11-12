CREATE PROCEDURE [dbo].[uspMFGetSalesOrderRecipe]
	@intSalesOrderId int,
	@intSalesOrderDetailId int
AS

Declare @intLocationId int
Declare @intItemId int
Declare @dblReqQty numeric(18,6)
Declare @intRecipeId int
Declare @dblRecipeQty numeric(18,6)
Declare @dblStandardQty numeric(18,6)
Declare @dtmOrderDueDate DateTime

Select @intLocationId=intCompanyLocationId,@dtmOrderDueDate=dtmDueDate From tblSOSalesOrder Where intSalesOrderId=@intSalesOrderId

Declare @tblItemFinal AS table
(
	intItemId int,
	strItemNo nvarchar(50),
	strDescription nvarchar(200),
	dblRequiredQty numeric(18,6),
	intItemUOMId int,
	strUOM nvarchar(50),
	dblAvailableQty numeric(18,6),
	strProcessName nvarchar(50),
	intRecipeId int,
	intWorkOrderId int,
	strWorkOrderNo nvarchar(50),
	dblWOQty numeric(18,6),
	dtmDueDate DateTime,
	intCellId int,
	intLocationId int,
	dtmOrderDueDate DateTime
)

--Sales Order Item
Insert Into @tblItemFinal(intItemId,strItemNo,strDescription,dblRequiredQty,intItemUOMId,strUOM,strProcessName,intRecipeId,intWorkOrderId,
strWorkOrderNo,dblWOQty,dtmDueDate,intCellId,intLocationId,dtmOrderDueDate)
Select r.intItemId,i.strItemNo,i.strDescription,sd.dblQtyOrdered AS dblRequiredQty,
sd.intItemUOMId,um.strUnitMeasure AS strUOM,mp.strProcessName,r.intRecipeId,ISNULL(w.intWorkOrderId,0),
w.strWorkOrderNo,w.dblQuantity,w.dtmExpectedDate,w.intManufacturingCellId,@intLocationId,@dtmOrderDueDate
From tblMFRecipe r 
Join tblSOSalesOrderDetail sd on r.intItemId=sd.intItemId
Join tblICItem i on r.intItemId=i.intItemId
Join tblICItemUOM iu on sd.intItemUOMId=iu.intItemUOMId
Join tblICUnitMeasure um on iu.intUnitMeasureId=um.intUnitMeasureId
Join tblMFManufacturingProcess mp on r.intManufacturingProcessId=mp.intManufacturingProcessId
Left Join tblMFWorkOrder w on sd.intSalesOrderDetailId=w.intSalesOrderLineItemId And w.intItemId=sd.intItemId
Where r.intLocationId=@intLocationId And r.ysnActive=1 And sd.intSalesOrderId=@intSalesOrderId 
And sd.intSalesOrderDetailId=@intSalesOrderDetailId

Select @intRecipeId=intRecipeId,@intItemId=intItemId,
@dblStandardQty=dbo.fnICConvertUOMtoStockUnit(intItemId,intItemUOMId,dblRequiredQty)
From @tblItemFinal
Select @dblRecipeQty=dblQuantity 
From tblMFRecipe Where intRecipeId=(Select intRecipeId From @tblItemFinal)

Update @tblItemFinal Set dblAvailableQty=(Select SUM(dblQty) 
From tblICLot Where intItemId=@intItemId And dblQty>0 And intLocationId=@intLocationId)

--Sales Order Recipe Item
Insert Into @tblItemFinal(intItemId,strItemNo,strDescription,dblRequiredQty,intItemUOMId,strUOM,strProcessName,intRecipeId,intWorkOrderId,
strWorkOrderNo,dblWOQty,dtmDueDate,intCellId,intLocationId,dtmOrderDueDate)
Select ri.intItemId,i.strItemNo,i.strDescription,(ri.dblCalculatedQuantity * (@dblStandardQty/@dblRecipeQty)) AS dblRequiredQty,
iu.intItemUOMId,um.strUnitMeasure AS strUOM,mp.strProcessName,r.intRecipeId,ISNULL(w.intWorkOrderId,0),
w.strWorkOrderNo,w.dblQuantity,w.dtmExpectedDate,w.intManufacturingCellId,@intLocationId,@dtmOrderDueDate
From tblMFRecipeItem ri 
Join tblICItem i on ri.intItemId=i.intItemId
Join tblICItemUOM iu on i.intItemId=iu.intItemId And iu.ysnStockUnit=1
Join tblICUnitMeasure um on iu.intUnitMeasureId=um.intUnitMeasureId 
Join tblMFRecipe r on ri.intReferenceRecipeId=r.intRecipeId
Join tblMFManufacturingProcess mp on r.intManufacturingProcessId=mp.intManufacturingProcessId
Left Join tblMFWorkOrder w on w.intItemId=r.intItemId And w.intSalesOrderLineItemId=@intSalesOrderDetailId
Where r.intLocationId=@intLocationId And r.ysnActive=1 And ri.intRecipeId=@intRecipeId

Select @intItemId=intItemId From @tblItemFinal Where dblAvailableQty is null 

Update @tblItemFinal Set dblAvailableQty=(Select SUM(dblWeight) 
From tblICLot Where intItemId=@intItemId And dblQty>0 And intLocationId=@intLocationId) 
Where dblAvailableQty is null

Select *,@intSalesOrderId AS intSalesOrderId,@intSalesOrderDetailId AS intSalesOrderDetailId From @tblItemFinal