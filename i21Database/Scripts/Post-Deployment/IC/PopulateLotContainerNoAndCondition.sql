------------------------------------------------------------------------------------------------------------------
-- IMPORTANT NOTE: REMOVE THIS SCRIPT ON 1730
-- Purpose: New fields are added to tblICLot. It is strContainerNo and strCondition.
-- Populate the existing lot records with data from Inventory Receipt. 
------------------------------------------------------------------------------------------------------------------
print('/*******************  BEGIN Populate Lot Container Number and Condition *******************/')
GO

-- Check if existing data were populated already. If yes, do not run the script. 
IF EXISTS (
	SELECT	TOP 1 1 
	FROM	tblICLot l INNER JOIN (
				tblICInventoryReceipt r INNER JOIN tblICInventoryReceiptItem ri
					ON r.intInventoryReceiptId = ri.intInventoryReceiptId
				INNER JOIN tblICInventoryReceiptItemLot ril
					ON ril.intInventoryReceiptItemId = ri.intInventoryReceiptItemId
			)
				ON l.intLotId = ril.intLotId
	WHERE	(ISNULL(ril.strContainerNo, '') <> '' OR ISNULL(ril.strCondition, '') <> '')
			AND NOT EXISTS (SELECT TOP 1 1 FROM tblICLot WHERE strContainerNo IS NOT NULL OR strCondition IS NOT NULL)
)
BEGIN 
	-- Populate the container no and condition for all lots having the same lot number and item id. 
	UPDATE	l
	SET		l.strContainerNo = ril.strContainerNo
			,l.strCondition = ril.strCondition 
	FROM	tblICLot l INNER JOIN (
				tblICInventoryReceipt r INNER JOIN tblICInventoryReceiptItem ri
					ON r.intInventoryReceiptId = ri.intInventoryReceiptId
				INNER JOIN tblICInventoryReceiptItemLot ril
					ON ril.intInventoryReceiptItemId = ri.intInventoryReceiptItemId
			)
				ON l.strLotNumber = ril.strLotNumber
				AND l.intItemId = ri.intItemId
END 

GO
print('/*******************  END Populate Lot Container Number and Condition *******************/')

