CREATE PROCEDURE [dbo].[uspICInventoryReceiptCalculateTotals] (
	@ReceiptId INT = NULL,
	@ForceRecalc BIT = 0
)
AS

DECLARE @intMaxId INT = ISNULL(@ReceiptId, 2147483647)
DECLARE @intMinId INT = ISNULL(@ReceiptId, 1) -- if allows negative seeds -2147483647
DECLARE @Date DATETIME = GETUTCDATE()

UPDATE r
SET
	  r.dtmLastCalculateTotals = @Date
	, r.dblSubTotal = ISNULL(dbo.fnICGetReceiptTotals(r.intInventoryReceiptId, 1),0)
	, r.dblTotalTax = ISNULL(dbo.fnICGetReceiptTotals(r.intInventoryReceiptId, 2),0)
	, r.dblTotalCharges = ISNULL(dbo.fnICGetReceiptTotals(r.intInventoryReceiptId, 3),0)
	, r.dblTotalGross = ISNULL(dbo.fnICGetReceiptTotals(r.intInventoryReceiptId, 4),0)
	, r.dblTotalNet =  ISNULL(dbo.fnICGetReceiptTotals(r.intInventoryReceiptId, 5),0)
	, r.dblGrandTotal =  ISNULL(dbo.fnICGetReceiptTotals(r.intInventoryReceiptId, 6),0)
FROM tblICInventoryReceipt r
WHERE (@ForceRecalc = 1 OR (r.dtmLastCalculateTotals IS NULL OR r.dtmDateModified > r.dtmLastCalculateTotals))
	AND (r.intInventoryReceiptId BETWEEN @intMinId AND @intMaxId)

-- Temporarily comment this out to resolve IC-7927 but will temporarily remove optimizations in IC-7893
--EXEC dbo.uspICUpdateInventoryReceiptDetail @ReceiptId, @ForceRecalc