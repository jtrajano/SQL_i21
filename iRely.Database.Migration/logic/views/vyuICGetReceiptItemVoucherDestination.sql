--liquibase formatted sql

-- changeset Von:vyuICGetReceiptItemVoucherDestination.sql.1 runOnChange:true splitStatements:false
-- comment: RK-1234

CREATE OR ALTER VIEW [dbo].[vyuICGetReceiptItemVoucherDestination]
AS 

SELECT
Receipt.intInventoryReceiptId,
ReceiptItem.intInventoryReceiptItemId,
Receipt.strReceiptNumber,
Receipt.intSourceType,
intDestinationId = Bill.intBillId,
strDestinationNo = Bill.strBillId
FROM
tblICInventoryReceipt Receipt
INNER JOIN tblICInventoryReceiptItem ReceiptItem
ON Receipt.intInventoryReceiptId = ReceiptItem.intInventoryReceiptId
INNER JOIN tblAPBillDetail BillDetail
ON ReceiptItem.intInventoryReceiptItemId = BillDetail.intInventoryReceiptItemId
INNER JOIN tblAPBill Bill
ON BillDetail.intBillId = Bill.intBillId



