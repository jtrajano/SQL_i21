CREATE PROCEDURE [dbo].[uspICValidateReceiptForReturn]
	@intReceiptId AS INT = NULL,
	@intReturnId AS INT = NULL
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

DECLARE @intItemId AS INT 
		,@strItemNo AS NVARCHAR(50)
	
-- Validate Inventory Return for any Over-Return.
IF @intReturnId IS NOT NULL 
BEGIN 
	SELECT	TOP 1 
			@intItemId = i.intItemId
			,@strItemNo = i.strItemNo
	FROM	tblICInventoryReceipt rtn INNER JOIN tblICInventoryReceiptItem rtnItem
				ON rtn.intInventoryReceiptId = rtnItem.intInventoryReceiptId
			INNER JOIN (
				tblICInventoryReceipt r INNER JOIN tblICInventoryReceiptItem ri
					ON r.intInventoryReceiptId = ri.intInventoryReceiptId					
			)
				ON ri.intInventoryReceiptItemId = rtnItem.intSourceInventoryReceiptItemId
			INNER JOIN tblICItem i 
				ON i.intItemId = ri.intItemId 
	WHERE	rtn.intInventoryReceiptId = @intReturnId
			AND (
				ISNULL(ri.dblQtyReturned, 0) > ISNULL(ri.dblOpenReceive, 0) 
				OR ISNULL(ri.dblNetReturned, 0) > ISNULL(ri.dblNet, 0) 
			)

	IF @intItemId IS NOT NULL 
	BEGIN 
		-- 'Transaction not saved. Stocks for {Item No} will have an over-return.'
		EXEC uspICRaiseError 80160, @strItemNo
		RETURN -1;
	END 
END 

-- Validate Inventory Receipt if fully returned. 
IF @intReceiptId IS NOT NULL 
BEGIN 
	SELECT	TOP 1 
			@intItemId = i.intItemId
			,@strItemNo = i.strItemNo
	FROM	tblICInventoryReceipt r INNER JOIN tblICInventoryReceiptItem ri
				ON r.intInventoryReceiptId = ri.intInventoryReceiptId					
			INNER JOIN tblICItem i 
				ON i.intItemId = ri.intItemId 
	WHERE	ri.intInventoryReceiptId = @intReceiptId
			AND (
				ISNULL(ri.dblQtyReturned, 0) < ISNULL(ri.dblOpenReceive, 0) 
				OR ISNULL(ri.dblNetReturned, 0) < ISNULL(ri.dblNet, 0) 
			)

	IF @intItemId IS NULL 
	BEGIN 
		-- 'Return no longer allowed. All of the stocks are returned.'
		EXEC uspICRaiseError 80161, @strItemNo;
		RETURN -1;
	END 
END 