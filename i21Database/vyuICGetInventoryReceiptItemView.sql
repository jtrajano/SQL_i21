CREATE VIEW [dbo].[vyuICGetInventoryReceiptItemView]
AS
SELECT
	ROW_NUMBER() OVER(ORDER BY ReceiptItem.intInventoryReceiptItemId DESC) As intRecordNo,
	ReceiptItem.intInventoryReceiptId,
	ReceiptItem.intInventoryReceiptItemId,
	ReceiptItem.intItemId,
	ReceiptItem.dblReceived,
	ReceiptItem.dblBillQty,
	ReceiptItem.intSourceId,
	ReceiptItemSource.strOrderNumber,
	ReceiptItemSource.strSourceNumber,
	ReceiptItemSource.strSourceType
FROM tblICInventoryReceiptItem ReceiptItem
	LEFT OUTER JOIN vyuICGetReceiptItemSource ReceiptItemSource
		ON ReceiptItemSource.intInventoryReceiptItemId = ReceiptItem.intInventoryReceiptItemId