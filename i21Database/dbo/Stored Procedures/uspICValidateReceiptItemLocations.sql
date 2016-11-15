CREATE PROCEDURE [dbo].[uspICValidateReceiptItemLocations]
	@intInventoryReceiptId INT,
	@ysnValid BIT OUTPUT,
	@strItemNo NVARCHAR(50) OUTPUT 
AS


DECLARE @intItemId AS INT 

--IF EXISTS(
--	SELECT r.intInventoryReceiptId, ri.intInventoryReceiptId, lot.intStorageLocationId, lot.intInventoryReceiptItemLotId, sc.intCompanyLocationId, sc.intCompanyLocationSubLocationId
--	FROM tblICInventoryReceipt r
--		LEFT JOIN tblSMCompanyLocation c ON c.intCompanyLocationId = r.intLocationId
--		LEFT JOIN tblICInventoryReceiptItem ri ON ri.intInventoryReceiptId = r.intInventoryReceiptId
--		LEFT JOIN tblSMCompanyLocationSubLocation sc ON sc.intCompanyLocationSubLocationId = ri.intSubLocationId
--			AND sc.intCompanyLocationId <> c.intCompanyLocationId
--		LEFT JOIN tblICInventoryReceiptItemLot lot ON lot.intInventoryReceiptItemId = ri.intInventoryReceiptItemId
--		LEFT OUTER JOIN tblICStorageLocation sl ON sl.intStorageLocationId = ri.intStorageLocationId
--			AND sl.intSubLocationId <> ri.intSubLocationId
--	WHERE r.intInventoryReceiptId = @intInventoryReceiptId
--		AND (sl.intStorageLocationId IS NOT NULL OR (sc.intCompanyLocationSubLocationId IS NOT NULL AND r.intLocationId <> sc.intCompanyLocationId))
--)
--	SET @ysnValid = 0
--ELSE
--	SET @ysnValid = 1


SELECT	TOP 1 
		@strItemNo = i.strItemNo
		,@intItemId = i.intItemId
FROM	tblICInventoryReceipt r LEFT JOIN tblSMCompanyLocation c 
			ON c.intCompanyLocationId = r.intLocationId
		LEFT JOIN tblICInventoryReceiptItem ri 
			ON ri.intInventoryReceiptId = r.intInventoryReceiptId
		LEFT JOIN tblSMCompanyLocationSubLocation sc 
			ON sc.intCompanyLocationSubLocationId = ri.intSubLocationId
			AND sc.intCompanyLocationId <> c.intCompanyLocationId
		LEFT JOIN tblICInventoryReceiptItemLot lot 
			ON lot.intInventoryReceiptItemId = ri.intInventoryReceiptItemId
		LEFT OUTER JOIN tblICStorageLocation sl 
			ON sl.intStorageLocationId = ri.intStorageLocationId
			AND sl.intSubLocationId <> ri.intSubLocationId
		LEFT JOIN tblICItem i 
			ON i.intItemId = ri.intItemId
WHERE	r.intInventoryReceiptId = @intInventoryReceiptId
		AND (
			sl.intStorageLocationId IS NOT NULL 
			OR (
				sc.intCompanyLocationSubLocationId IS NOT NULL 
				AND r.intLocationId <> sc.intCompanyLocationId
			)
		)

SET @ysnValid = CASE WHEN @intItemId IS NOT NULL THEN 0 ELSE 1 END 