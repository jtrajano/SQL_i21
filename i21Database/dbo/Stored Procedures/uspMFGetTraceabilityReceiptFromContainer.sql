CREATE PROCEDURE [dbo].[uspMFGetTraceabilityReceiptFromContainer]
	@intContainerId int
AS
SET NOCOUNT ON;

Select DISTINCT 'Receipt' AS strTransactionName,rh.intInventoryReceiptId,rh.strReceiptNumber,'' AS strLotAlias,i.intItemId,i.strItemNo,i.strDescription,
mt.intCategoryId,mt.strCategoryCode,ri.dblOrderQty AS dblQuantity,
um.strUnitMeasure AS strUOM,
rh.dtmReceiptDate AS dtmTransactionDate,0 intParentLotId,v.strName AS strVendor,'R' AS strType
from tblICInventoryReceiptItem ri
Join tblICInventoryReceipt rh on rh.intInventoryReceiptId=ri.intInventoryReceiptId
Join tblICItem i on ri.intItemId=i.intItemId
Join tblICCategory mt on mt.intCategoryId=i.intCategoryId
Left Join tblICItemUOM iu on ri.intUnitMeasureId=iu.intItemUOMId
Left Join tblICUnitMeasure um on iu.intUnitMeasureId=um.intUnitMeasureId
Left Join vyuAPVendor v on rh.intEntityVendorId=v.[intEntityId]
Where ri.intContainerId=@intContainerId
