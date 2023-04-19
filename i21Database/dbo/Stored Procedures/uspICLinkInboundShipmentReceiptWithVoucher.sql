CREATE PROCEDURE uspICLinkInboundShipmentReceiptWithVoucher
	@intBillId INT = NULL
	,@intInventoryReceiptId INT = NULL 
AS

DECLARE @inboundShipment AS INT = 2
DECLARE @intContractDetailId AS INT
DECLARE @intLoadDetailId AS INT

SELECT 
	@intContractDetailId = intLineNo,
	@intLoadDetailId = intSourceId
FROM tblICInventoryReceiptItem
WHERE intInventoryReceiptId = @intInventoryReceiptId

If(OBJECT_ID('tempdb..#tempTblAPBillDetail') Is Not Null)
Begin
    Drop Table #tempTblAPBillDetail
End

If(OBJECT_ID('tempdb..#tempTblICInventoryReceiptItem') Is Not Null)
Begin
    Drop Table #tempTblICInventoryReceiptItem
End

If(OBJECT_ID('tempdb..#tempLink') Is Not Null)
Begin
    Drop Table #tempLink
End

CREATE TABLE #tempTblAPBillDetail
(
    intId int, 
    intBillDetailId int,
)

CREATE TABLE #tempTblICInventoryReceiptItem
(
    intId int, 
	intInventoryReceiptItemId int
)

CREATE TABLE #tempLink
(
	intInventoryReceiptItemId int,
    intBillDetailId int,
)

INSERT INTO #tempTblAPBillDetail (intBillDetailId, intId)
SELECT intBillDetailId, ROW_NUMBER() OVER (ORDER BY intBillDetailId)
FROM tblAPBillDetail
WHERE
	intContractDetailId = @intContractDetailId
	AND intLoadDetailId = @intLoadDetailId

INSERT INTO #tempTblICInventoryReceiptItem (intInventoryReceiptItemId, intId)
SELECT RI.intInventoryReceiptItemId, ROW_NUMBER() OVER (ORDER BY RI.intInventoryReceiptItemId)
FROM tblICInventoryReceiptItem RI
INNER JOIN tblICInventoryReceipt R ON R.intInventoryReceiptId = RI.intInventoryReceiptId
	AND R.intSourceType = @inboundShipment
	AND R.strReceiptType = 'Purchase Contract'
	AND R.ysnPosted = 1
WHERE 
	R.intInventoryReceiptId = @intInventoryReceiptId
	AND RI.intSourceId = @intLoadDetailId

INSERT INTO #tempLink (intInventoryReceiptItemId, intBillDetailId)
SELECT TRI.intInventoryReceiptItemId, TBD.intBillDetailId
FROM #tempTblICInventoryReceiptItem TRI
INNER JOIN #tempTblAPBillDetail TBD ON TBD.intId = TRI.intId

UPDATE BD
SET BD.intInventoryReceiptItemId = TL.intInventoryReceiptItemId
FROM tblAPBillDetail BD
INNER JOIN #tempLink TL ON BD.intBillDetailId = TL.intBillDetailId

UPDATE tblAPBillDetail
SET ysnStage = 0
WHERE
	intContractDetailId = @intContractDetailId
	AND intLoadDetailId = @intLoadDetailId
	AND intInventoryReceiptItemId IS NULL