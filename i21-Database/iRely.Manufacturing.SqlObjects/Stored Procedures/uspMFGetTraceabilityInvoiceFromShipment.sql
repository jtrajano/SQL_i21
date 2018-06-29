CREATE PROCEDURE [dbo].[uspMFGetTraceabilityInvoiceFromShipment]
	@intShipmentId int
AS
SET NOCOUNT ON;

Select DISTINCT 'Invoice' AS strTransactionName,iv.intInvoiceId,iv.strInvoiceNumber,'' AS strLotAlias,i.intItemId,i.strItemNo,i.strDescription,
mt.intCategoryId,mt.strCategoryCode,ivd.dblQtyOrdered AS dblQuantity,
um.strUnitMeasure AS strUOM,
iv.dtmDate AS dtmTransactionDate,c.strName AS strVendor,'IN' AS strType
from tblARInvoice iv
Join tblARInvoiceDetail ivd on iv.intInvoiceId=ivd.intInvoiceId
Join tblICInventoryShipmentItem si on si.intInventoryShipmentItemId=ivd.intInventoryShipmentItemId
Join tblICInventoryShipment sh on sh.intInventoryShipmentId=si.intInventoryShipmentId
Join tblICItem i on si.intItemId=i.intItemId
Join tblICCategory mt on mt.intCategoryId=i.intCategoryId
Left Join tblICItemUOM iu on ivd.intItemUOMId=iu.intItemUOMId
Left Join tblICUnitMeasure um on iu.intUnitMeasureId=um.intUnitMeasureId
Left Join vyuARCustomer c on iv.intEntityCustomerId=c.[intEntityId]
Where sh.intInventoryShipmentId=@intShipmentId
