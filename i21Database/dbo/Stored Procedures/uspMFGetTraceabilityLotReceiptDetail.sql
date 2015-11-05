﻿CREATE PROCEDURE [dbo].[uspMFGetTraceabilityLotReceiptDetail]
	@intLotId int
AS
SET NOCOUNT ON;

	Select 'Receipt' AS strTransactionName,l.intLotId,l.strLotNumber,l.strLotAlias,i.intItemId,i.strItemNo,i.strDescription,
	mt.strCategoryCode,CASE WHEN l.intWeightUOMId is null then rm.dblQuantity Else rm.dblGrossWeight End AS dblQuantity,
	CASE WHEN l.intWeightUOMId is null then um.strUnitMeasure Else um1.strUnitMeasure End AS strUOM,
	l.dtmDateCreated AS dtmTransactionDate,l.intParentLotId,v.strName AS strVendor,'L' AS strType
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
	Left Join vyuAPVendor v on l.intEntityVendorId=v.intEntityVendorId
	Where l.intLotId=@intLotId
