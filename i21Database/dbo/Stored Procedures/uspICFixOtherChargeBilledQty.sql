CREATE PROCEDURE uspICFixOtherChargeBilledQty
AS 

SET QUOTED_IDENTIFIER OFF  
SET ANSI_NULLS ON  
SET NOCOUNT ON  
SET XACT_ABORT ON  
SET ANSI_WARNINGS ON  

-- Reset the Qty and Amount Billed and Priced. 
UPDATE rc
SET
	rc.dblQuantityBilled = 0
	,rc.dblQuantityPriced = 0 
	,rc.dblAmountBilled = 0 
	,rc.dblAmountPriced = 0 
FROM 
	tblICInventoryReceipt r INNER JOIN tblICInventoryReceiptCharge rc
		ON r.intInventoryReceiptId = rc.intInventoryReceiptId
WHERE
	r.ysnPosted = 1

-- Gather the data from the voucher table. 
DECLARE @updateDetail AS InventoryUpdateBillQty
INSERT INTO @updateDetail
(
	[intInventoryReceiptItemId]
	,[intInventoryReceiptChargeId]
	,[intInventoryShipmentChargeId]
	,[intSourceTransactionNoId]
	,[strSourceTransactionNo]
	,[intItemId]
	,[intToBillUOMId]
	,[dblToBillQty]
	,[intEntityVendorId]
	,[dblAmountToBill]
)
SELECT 
	[intInventoryReceiptItemId] = NULL 
	,[intInventoryReceiptChargeId] = bd.intInventoryReceiptChargeId
	,[intInventoryShipmentChargeId] = NULL 
	,[intSourceTransactionNoId] = b.intBillId
	,[strSourceTransactionNo] = b.strBillId
	,[intItemId] = bd.intItemId
	,[intToBillUOMId] = bd.intUnitOfMeasureId
	,[dblToBillQty] = bd.dblQtyReceived
	,[intEntityVendorId] = b.intEntityVendorId
	,[dblAmountToBill] = 
				CASE WHEN ISNULL(bd.intCostUOMId, bd.intUnitOfMeasureId) IS NULL THEN 
					ROUND(bd.dblCost, 2) 
				ELSE 
					ROUND(
						dbo.fnMultiply(
							dbo.fnCalculateCostBetweenUOM(
								ISNULL(bd.intCostUOMId, bd.intUnitOfMeasureId)
								,bd.intUnitOfMeasureId
								,bd.dblCost
							)
							,ABS(bd.dblQtyReceived)
						)
						,2
					)
				END
FROM	
	tblAPBill b INNER JOIN tblAPBillDetail bd
		ON b.intBillId = bd.intBillId
WHERE
	bd.intInventoryReceiptChargeId IS NOT NULL 

-- Call the IC sp to re-updated the billed qty
EXEC uspICUpdateBillQty @updateDetail