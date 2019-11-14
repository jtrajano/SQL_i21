CREATE PROCEDURE [dbo].[uspICUpdateReceiptCharge]
	@intContractHeaderId AS INT = NULL 
	,@intContractDetailId AS INT = NULL 
	,@dblAmount AS NUMERIC(18, 2) = 0 
	,@intInventoryReceiptId AS INT = NULL 
	,@strReceiptNumber AS NVARCHAR(50) = NULL 	
	,@intChargeId AS INT = NULL 
AS

DECLARE @SourceType_NONE AS INT = 0
		,@SourceType_SCALE AS INT = 1
		,@SourceType_INBOUND_SHIPMENT AS INT = 2
		,@SourceType_TRANSPORT AS INT = 3
		,@SourceType_SETTLE_STORAGE AS INT = 4
		,@SourceType_DELIVERY_SHEET AS INT = 5
		,@SourceType_PURCHASE_ORDER AS INT = 6
		,@SourceType_STORE AS INT = 7
		,@SourceType_STORE_LOTTERY_MODULE AS INT = 8

DECLARE @intInventoryReceiptChargeId AS INT 
		,@inventoryReceiptId AS INT 

BEGIN 
	DECLARE @TransactionName AS VARCHAR(500) = 'uspICUpdateReceiptCharge_' + CAST(NEWID() AS NVARCHAR(100));
	BEGIN TRAN @TransactionName
	SAVE TRAN @TransactionName
END

UPDATE TOP (1) rc
SET 
	rc.dblAmount = ISNULL(rc.dblAmount, 0) + ISNULL(@dblAmount, 0) 
	,@intInventoryReceiptChargeId = rc.intInventoryReceiptChargeId
	,@inventoryReceiptId = rc.intInventoryReceiptId
FROM 
	tblICInventoryReceipt r INNER JOIN tblICInventoryReceiptCharge rc
		ON r.intInventoryReceiptId = rc.intInventoryReceiptId
WHERE
	(
		(r.strReceiptNumber = @strReceiptNumber AND @intInventoryReceiptId IS NULL)
		OR (r.intInventoryReceiptId = @intInventoryReceiptId AND @strReceiptNumber IS NULL)
		OR (r.strReceiptNumber = @strReceiptNumber AND r.intInventoryReceiptId = @intInventoryReceiptId) 
	)
	AND (rc.intContractId = @intContractHeaderId OR @intContractHeaderId IS NULL)
	AND (rc.intContractDetailId = @intContractDetailId OR @intContractDetailId IS NULL) 
	AND (rc.intChargeId = @intChargeId OR @intChargeId IS NULL) 
	AND ISNULL(r.ysnPosted,0) = 0
	AND rc.strCostMethod = 'Amount'

-- Re-calculate the other charges
BEGIN 			
	-- Calculate the other charges. 
	EXEC dbo.uspICCalculateInventoryReceiptOtherCharges
		@inventoryReceiptId			

	-- Calculate the surcharges
	EXEC dbo.uspICCalculateInventoryReceiptSurchargeOnOtherCharges
		@inventoryReceiptId
			
	-- Allocate the other charges and surcharges. 
	EXEC dbo.uspICAllocateInventoryReceiptOtherCharges 
		@inventoryReceiptId		
				
	-- Calculate Other Charges Taxes
	EXEC dbo.uspICCalculateInventoryReceiptOtherChargesTaxes
		@inventoryReceiptId
END 

-- Validate the receipt total. Do not allow negative receipt total. 
-- However, allow it if source type is a 'STORE'
IF EXISTS (
	SELECT 1
	FROM	tblICInventoryReceipt r
	WHERE	r.intInventoryReceiptId = @inventoryReceiptId
			AND dbo.fnICGetReceiptTotals(@inventoryReceiptId, 6) < 0
			AND r.intSourceType <> @SourceType_STORE 
) 
BEGIN
	-- Unable to update the Other Charge. The Inventory Receipt total is going to be negative.
	EXEC uspICRaiseError 80242;
	GOTO _Exit_With_Rollback;
END

IF @@TRANCOUNT > 0
BEGIN 
	COMMIT TRAN @TransactionName
	GOTO _Exit
END 

_Exit_With_Rollback:
IF @@TRANCOUNT > 0 
BEGIN 
	ROLLBACK TRAN @TransactionName
	COMMIT TRAN @TransactionName
END

_Exit: