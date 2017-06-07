CREATE PROCEDURE [dbo].[uspMFGetTraceabilityReceiptDetail]
	@intInventoryReceiptId int
AS

SET NOCOUNT ON;

Declare @dblReceiptQuantity numeric(38,20)
Declare @strUOM nvarchar(50)

Select @dblReceiptQuantity=SUM(ISNULL(dblOrderQty,0)) From tblICInventoryReceiptItem Where intInventoryReceiptId=@intInventoryReceiptId

Select TOP 1 @strUOM=um.strUnitMeasure From tblICItemUOM iu Join tblICInventoryReceiptItem sd on iu.intItemUOMId=sd.intUnitMeasureId
Join tblICUnitMeasure um on iu.intUnitMeasureId=um.intUnitMeasureId

Select DISTINCT 'Receipt' AS strTransactionName,rh.intInventoryReceiptId,rh.strReceiptNumber,'' AS strLotAlias,0 intItemId,'' strItemNo,'' strDescription,
0 intCategoryId,'' strCategoryCode,@dblReceiptQuantity AS dblQuantity,
@strUOM AS strUOM,
rh.dtmReceiptDate AS dtmTransactionDate,v.strName AS strVendor,'R' AS strType
from tblICInventoryReceipt rh
Left Join vyuAPVendor v on rh.intEntityVendorId=v.[intEntityId]
Where rh.intInventoryReceiptId=@intInventoryReceiptId
