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
Declare @intWorkOrderId int
Declare @strWorkOrderNo nVarchar(Max) --Multiple WorkOrders for Blending
Declare @dblWOQty numeric(18,6)
Declare @dtmDueDate DateTime
Declare @intCellId int
Declare @dblAvailableQty numeric(18,6)

Select @intLocationId=intCompanyLocationId,@dtmOrderDueDate=dtmDueDate From tblSOSalesOrder Where intSalesOrderId=@intSalesOrderId

Declare @tblItemFinal AS table
(
	intRowNo int IDENTITY(1,1),
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
	strWorkOrderNo nvarchar(Max),
	dblWOQty numeric(18,6),
	dtmDueDate DateTime,
	intCellId int,
	intLocationId int,
	dtmOrderDueDate DateTime,
	intManufacturingProcessId int
)

--Sales Order Item
Insert Into @tblItemFinal(intItemId,strItemNo,strDescription,dblRequiredQty,intItemUOMId,strUOM,strProcessName,intRecipeId,intWorkOrderId,
strWorkOrderNo,dblWOQty,dtmDueDate,intCellId,intLocationId,dtmOrderDueDate,intManufacturingProcessId)
Select r.intItemId,i.strItemNo,i.strDescription,sd.dblQtyOrdered AS dblRequiredQty,
sd.intItemUOMId,um.strUnitMeasure AS strUOM,mp.strProcessName,r.intRecipeId,
--ISNULL(w.intWorkOrderId,0),w.strWorkOrderNo,w.dblQuantity,w.dtmExpectedDate,w.intManufacturingCellId,
0 AS intWorkOrderId,'' AS strWorkOrderNo,0.0 AS dblQuantity,NULL AS dtmExpectedDate,0 AS intManufacturingCellId,
@intLocationId,@dtmOrderDueDate,mp.intManufacturingProcessId
From tblMFRecipe r 
Join tblSOSalesOrderDetail sd on r.intItemId=sd.intItemId
Join tblICItem i on r.intItemId=i.intItemId
Join tblICItemUOM iu on sd.intItemUOMId=iu.intItemUOMId
Join tblICUnitMeasure um on iu.intUnitMeasureId=um.intUnitMeasureId
Join tblMFManufacturingProcess mp on r.intManufacturingProcessId=mp.intManufacturingProcessId
--Left Join tblMFWorkOrder w on sd.intSalesOrderDetailId=w.intSalesOrderLineItemId And w.intItemId=sd.intItemId
Where r.intLocationId=@intLocationId And r.ysnActive=1 And sd.intSalesOrderId=@intSalesOrderId 
And sd.intSalesOrderDetailId=@intSalesOrderDetailId

Select @intRecipeId=intRecipeId,@intItemId=intItemId,
@dblStandardQty=dbo.fnICConvertUOMtoStockUnit(intItemId,intItemUOMId,dblRequiredQty)
From @tblItemFinal
Select @dblRecipeQty=dblQuantity 
From tblMFRecipe Where intRecipeId=(Select intRecipeId From @tblItemFinal)

select @dblAvailableQty=SUM(dbo.[fnMFConvertQuantityToTargetItemUOM](v.intItemUOMId,f.intItemUOMId,v.dblAvailableNoOfPacks)) 
from vyuMFInventoryView v join @tblItemFinal f on v.intItemId=f.intItemId where v.intItemId=@intItemId and v.dblQty>0 and v.intLocationId=@intLocationId

Select TOP 1 @intWorkOrderId=ISNULL(intWorkOrderId,0),
@dblWOQty=dblQuantity,@dtmDueDate=dtmExpectedDate,@intCellId=intManufacturingCellId 
From tblMFWorkOrder Where intItemId=@intItemId And intSalesOrderLineItemId=@intSalesOrderDetailId

SELECT @strWorkOrderNo= STUFF((SELECT ',' + strWorkOrderNo 
            FROM tblMFWorkOrder Where intItemId=@intItemId And intSalesOrderLineItemId=@intSalesOrderDetailId
            FOR XML PATH('')) ,1,1,'')
	
Update @tblItemFinal Set intWorkOrderId=ISNULL(@intWorkOrderId,0),strWorkOrderNo=@strWorkOrderNo,dblWOQty=@dblWOQty,dtmDueDate=@dtmDueDate,intCellId=@intCellId,
dblAvailableQty=@dblAvailableQty

--Sales Order Recipe Item for next process
Insert Into @tblItemFinal(intItemId,strItemNo,strDescription,dblRequiredQty,intItemUOMId,strUOM,strProcessName,intRecipeId,intWorkOrderId,
strWorkOrderNo,dblWOQty,dtmDueDate,intCellId,intLocationId,dtmOrderDueDate,intManufacturingProcessId)
Select ri.intItemId,i.strItemNo,i.strDescription,(ri.dblCalculatedQuantity * (@dblStandardQty/@dblRecipeQty)) AS dblRequiredQty,
iu.intItemUOMId,um.strUnitMeasure AS strUOM,mp.strProcessName,r.intRecipeId,
--ISNULL(w.intWorkOrderId,0),w.strWorkOrderNo,w.dblQuantity,w.dtmExpectedDate,w.intManufacturingCellId,
0 AS intWorkOrderId,'' AS strWorkOrderNo,0.0 AS dblQuantity,NULL AS dtmExpectedDate,0 AS intManufacturingCellId,
@intLocationId,@dtmOrderDueDate,mp.intManufacturingProcessId
From tblMFRecipeItem ri 
Join tblICItem i on ri.intItemId=i.intItemId
Join tblICItemUOM iu on i.intItemId=iu.intItemId And iu.ysnStockUnit=1
Join tblICUnitMeasure um on iu.intUnitMeasureId=um.intUnitMeasureId 
Join tblMFRecipe r on ri.intItemId=r.intItemId
Join tblMFManufacturingProcess mp on r.intManufacturingProcessId=mp.intManufacturingProcessId
--Left Join tblMFWorkOrder w on w.intItemId=r.intItemId And w.intSalesOrderLineItemId=@intSalesOrderDetailId
Where r.intLocationId=@intLocationId And r.ysnActive=1 And ri.intRecipeId=@intRecipeId And ri.intRecipeItemTypeId=1

Select @intItemId=intItemId From @tblItemFinal Where intRowNo=2

Set @intWorkOrderId=0
Set @strWorkOrderNo=null
Set @dblWOQty=null
Set @dtmDueDate=null
Set @intCellId=null

Select TOP 1 @intWorkOrderId=ISNULL(intWorkOrderId,0),
@dblWOQty=dblQuantity,@dtmDueDate=dtmExpectedDate,@intCellId=intManufacturingCellId 
From tblMFWorkOrder Where intItemId=@intItemId And intSalesOrderLineItemId=@intSalesOrderDetailId

SELECT @strWorkOrderNo= STUFF((SELECT ',' + strWorkOrderNo 
            FROM tblMFWorkOrder Where intItemId=@intItemId And intSalesOrderLineItemId=@intSalesOrderDetailId
            FOR XML PATH('')) ,1,1,'')

Update @tblItemFinal Set intWorkOrderId=ISNULL(@intWorkOrderId,0),strWorkOrderNo=@strWorkOrderNo,dblWOQty=@dblWOQty,dtmDueDate=@dtmDueDate,intCellId=@intCellId
Where intRowNo=2

Update f set f.dblAvailableQty=t.dblAvailableQty From @tblItemFinal f
Join
(select f.intItemId, SUM(dbo.[fnMFConvertQuantityToTargetItemUOM](v.intItemUOMId,f.intItemUOMId,v.dblAvailableNoOfPacks)) dblAvailableQty
from vyuMFInventoryView v join @tblItemFinal f on v.intItemId=f.intItemId where v.dblQty>0 and v.intLocationId=@intLocationId
and f.intRowNo>1 group by f.intItemId
) t on f.intItemId=t.intItemId and f.intRowNo>1

--Final Select
Select *,@intSalesOrderId AS intSalesOrderId,@intSalesOrderDetailId AS intSalesOrderDetailId From @tblItemFinal