CREATE PROCEDURE [dbo].[uspMFGetTraceabilityShipmentDetail]
	@intInventoryShipmentId int
AS

Declare @dblShipQuantity numeric(38,20)
Declare @strUOM nvarchar(50)

Select @dblShipQuantity=SUM(ISNULL(dblQuantity,0)) From tblICInventoryShipmentItem Where intInventoryShipmentId=@intInventoryShipmentId

Select TOP 1 @strUOM=um.strUnitMeasure From tblICItemUOM iu Join tblICInventoryShipmentItem sd on iu.intItemUOMId=sd.intItemUOMId
Join tblICUnitMeasure um on iu.intUnitMeasureId=um.intUnitMeasureId

Select 'Ship' AS strTransactionName,sh.intInventoryShipmentId,sh.strShipmentNumber,'' AS strLotAlias,0 intItemId,'' strItemNo,'' strDescription,
0 intCategoryId,'' strCategoryCode,@dblShipQuantity AS dblQuantity,
@strUOM AS strUOM,
sh.dtmShipDate AS dtmTransactionDate,c.strName ,'S' AS strType
from tblICInventoryShipment sh 
Left Join vyuARCustomer c on sh.intEntityCustomerId=c.[intEntityId]
Where sh.intInventoryShipmentId=@intInventoryShipmentId
