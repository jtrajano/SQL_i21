CREATE PROCEDURE [dbo].[uspICValidateAllocateInventoryReceiptOtherCharges]
	@intInventoryReceiptId AS INT 
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

DECLARE @strReceiptNumber AS NVARCHAR(50)
	,@strChargeName AS NVARCHAR(50)

SELECT TOP 1
	@strReceiptNumber = r.strReceiptNumber	
	,@strChargeName = charge.strItemNo
FROM 
	tblICInventoryReceipt r INNER JOIN tblICInventoryReceiptCharge rc
		ON r.intInventoryReceiptId = rc.intInventoryReceiptId
	INNER JOIN tblICItem charge
		ON charge.intItemId = rc.intChargeId
	OUTER APPLY (
		SELECT TOP 1 
			ri.intInventoryReceiptItemId
			,ri.intOwnershipType			
		FROM 
			tblICInventoryReceiptItem ri
		WHERE
			ri.intInventoryReceiptId = r.intInventoryReceiptId
			AND (
				(				
					ISNULL(rc.intContractId, 0) = COALESCE(ri.intContractHeaderId, ri.intOrderId, 0)
					AND ISNULL(rc.intContractDetailId, 0) = COALESCE(ri.intContractDetailId, ri.intLineNo, 0) 
					AND ISNULL(ri.strChargesLink, '') = ISNULL(rc.strChargesLink, '')									
				) OR (
					rc.strChargesLink IS NULL 
				)
			)
	) topItemLinkedToCharge

	outer apply (
		select top 1 
			ri.intInventoryReceiptItemId
			,ri.intOwnershipType			
		from 
			tblICInventoryReceiptItem ri
		where
			ri.intInventoryReceiptId = r.intInventoryReceiptId
			and (
				(				
					ISNULL(rc.intContractId, 0) = COALESCE(ri.intContractHeaderId, ri.intOrderId, 0)
					AND ISNULL(rc.intContractDetailId, 0) = COALESCE(ri.intContractDetailId, ri.intLineNo, 0) 
					AND ISNULL(ri.strChargesLink, '') = ISNULL(rc.strChargesLink, '')									
				) OR (
					rc.strChargesLink IS NULL 
				)
			)
			and ri.intOwnershipType = 1
	) topCompanyOwnedItemLinkedToCharge

	OUTER APPLY (
		SELECT TOP 1 
			ri.intInventoryReceiptItemId
			,ri.intOwnershipType			
		FROM 
			tblICInventoryReceiptItem ri
		WHERE
			ri.intInventoryReceiptId = r.intInventoryReceiptId
			and ri.intOwnershipType = 1
	) topCompanyOwnedItem

	OUTER APPLY (
		SELECT TOP 1 *
		FROM 
			tblICInventoryReceiptItemAllocatedCharge ac
		WHERE
			ac.intInventoryReceiptId = rc.intInventoryReceiptId
			and ac.intInventoryReceiptChargeId = rc.intInventoryReceiptChargeId
	) a
WHERE
	rc.ysnInventoryCost = 1
	AND ISNULL(rc.dblAmount, 0) <> 0 
	AND 1 = 
		CASE 
			WHEN a.intInventoryReceiptItemAllocatedChargeId IS NULL THEN -- No allocation
				CASE 
					WHEN 
						topItemLinkedToCharge.intInventoryReceiptItemId IS NOT NULL -- Charge is linked to an item. 
						AND topCompanyOwnedItemLinkedToCharge.intInventoryReceiptItemId IS NULL -- Charge is not linked to a company owned item.
					THEN 0

					WHEN 
						topItemLinkedToCharge.intInventoryReceiptItemId IS NULL -- Charge is not linked to any item 
						AND topCompanyOwnedItem.intInventoryReceiptItemId IS NOT NULL -- But there are company owned items. 
					THEN 1

					ELSE 1 -- Otherwise, assume the missing allocation is bad.  
				END			
			ELSE 0
		END 

IF @strReceiptNumber IS NOT NULL 
BEGIN 
	--  '{Charge Name} charges is not linked to any items. Please check if Charges Link in {Receipt Number} were properly assigned.'
	EXEC uspICRaiseError 80253, @strChargeName, @strReceiptNumber
END 