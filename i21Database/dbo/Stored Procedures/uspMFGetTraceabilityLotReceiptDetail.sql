CREATE PROCEDURE [dbo].[uspMFGetTraceabilityLotReceiptDetail]
	@intLotId int,
	@ysnParentLot bit=0
AS
SET NOCOUNT ON;

Declare @strLotNumber nvarchar(50)

Select @strLotNumber=strLotNumber From tblICLot Where intLotId=@intLotId

If @ysnParentLot=0
	Select 'Receipt' AS strTransactionName,rh.intInventoryReceiptId,rh.strReceiptNumber,'' AS strLotAlias,i.intItemId,i.strItemNo,i.strDescription,
	mt.intCategoryId,mt.strCategoryCode,CASE WHEN l.intWeightUOMId is null then rm.dblQuantity Else rm.dblGrossWeight End AS dblQuantity,
	CASE WHEN l.intWeightUOMId is null then um.strUnitMeasure Else um1.strUnitMeasure End AS strUOM,
	rh.dtmReceiptDate AS dtmTransactionDate,l.intParentLotId,v.strName AS strVendor,'R' AS strType
	from tblICInventoryReceiptItemLot rm  
	Join tblICInventoryReceiptItem rl on rm.intInventoryReceiptItemId=rl.intInventoryReceiptItemId
	Join tblICInventoryReceipt rh on rh.intInventoryReceiptId=rl.intInventoryReceiptId
	Join tblICLot l on rm.intLotId=l.intLotId
	Join tblICItem i on l.intItemId=i.intItemId
	Join tblICCategory mt on mt.intCategoryId=i.intCategoryId
	Join tblICItemUOM iu on l.intItemUOMId=iu.intItemUOMId
	Join tblICUnitMeasure um on iu.intUnitMeasureId=um.intUnitMeasureId
	Left Join tblICItemUOM iu1 on l.intWeightUOMId=iu1.intItemUOMId
	Left Join tblICUnitMeasure um1 on iu1.intUnitMeasureId=um1.intUnitMeasureId
	Left Join vyuAPVendor v on rh.intEntityVendorId=v.[intEntityId]
	Where l.intLotId IN (Select intLotId From tblICLot Where strLotNumber=@strLotNumber)

If @ysnParentLot=1
	Select TOP 1 'Receipt' AS strTransactionName,rh.intInventoryReceiptId,rh.strReceiptNumber,'' AS strLotAlias,i.intItemId,i.strItemNo,i.strDescription,
	mt.intCategoryId,mt.strCategoryCode,CASE WHEN l.intWeightUOMId is null then rm.dblQuantity Else rm.dblGrossWeight End AS dblQuantity,
	CASE WHEN l.intWeightUOMId is null then um.strUnitMeasure Else um1.strUnitMeasure End AS strUOM,
	rh.dtmReceiptDate AS dtmTransactionDate,l.intParentLotId,v.strName AS strVendor,'R' AS strType
	from tblICInventoryReceiptItemLot rm  
	Join tblICInventoryReceiptItem rl on rm.intInventoryReceiptItemId=rl.intInventoryReceiptItemId
	Join tblICInventoryReceipt rh on rh.intInventoryReceiptId=rl.intInventoryReceiptId
	Join tblICLot l on rm.intLotId=l.intLotId
	Join tblICItem i on l.intItemId=i.intItemId
	Join tblICCategory mt on mt.intCategoryId=i.intCategoryId
	Join tblICItemUOM iu on l.intItemUOMId=iu.intItemUOMId
	Join tblICUnitMeasure um on iu.intUnitMeasureId=um.intUnitMeasureId
	Left Join tblICItemUOM iu1 on l.intWeightUOMId=iu1.intItemUOMId
	Left Join tblICUnitMeasure um1 on iu1.intUnitMeasureId=um1.intUnitMeasureId
	Left Join vyuAPVendor v on rh.intEntityVendorId=v.[intEntityId]
	Where l.intParentLotId=@intLotId
