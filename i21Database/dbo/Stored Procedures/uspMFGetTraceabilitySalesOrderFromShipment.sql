CREATE PROCEDURE [dbo].[uspMFGetTraceabilitySalesOrderFromShipment]
	@intShipmentId int
AS
SET NOCOUNT ON;

Select DISTINCT 'Sales Order' AS strTransactionName,so.intSalesOrderId,so.strSalesOrderNumber,'' AS strLotAlias,i.intItemId,i.strItemNo,i.strDescription,
mt.intCategoryId,mt.strCategoryCode,sd.dblQtyOrdered AS dblQuantity,
um.strUnitMeasure AS strUOM,
so.dtmDate AS dtmTransactionDate,c.strName AS strVendor,'SO' AS strType
from tblSOSalesOrder so
Join tblSOSalesOrderDetail sd on so.intSalesOrderId=sd.intSalesOrderId
Join tblICInventoryShipmentItem si on si.intLineNo=sd.intSalesOrderDetailId
Join tblICInventoryShipment sh on sh.intInventoryShipmentId=si.intInventoryShipmentId AND sh.intOrderType=2
Join tblICItem i on si.intItemId=i.intItemId
Join tblICCategory mt on mt.intCategoryId=i.intCategoryId
Left Join tblICItemUOM iu on sd.intItemUOMId=iu.intItemUOMId
Left Join tblICUnitMeasure um on iu.intUnitMeasureId=um.intUnitMeasureId
Left Join vyuARCustomer c on so.intEntityCustomerId=c.[intEntityId]
Where sh.intInventoryShipmentId=@intShipmentId
