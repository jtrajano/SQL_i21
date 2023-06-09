CREATE PROCEDURE [dbo].[uspICFixOtherChargeGLEntries]
	@strReceiptNumber AS NVARCHAR(50) 
	,@dtmDate AS DATETIME 
AS

RETURN; 

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS ON

-- Create the temp table for the specific items/categories to rebuild
IF OBJECT_ID('tempdb..#tmpRebuildList') IS NULL  
BEGIN 
	CREATE TABLE #tmpRebuildList (
		intItemId INT NULL 
		,intCategoryId INT NULL 
	)	
END 

UPDATE affectedGd
SET 
	affectedGd.intAccountId = expectedGLInventoryAccount.intAccountId
FROM
	tblICInventoryReceipt r INNER JOIN tblICInventoryReceiptCharge rc
		ON r.intInventoryReceiptId = rc.intInventoryReceiptId
	INNER JOIN tblICInventoryReceiptItemAllocatedCharge allocCharge
		ON allocCharge.intInventoryReceiptChargeId = rc.intInventoryReceiptChargeId
	INNER JOIN tblICInventoryReceiptItem ri
		ON ri.intInventoryReceiptItemId = allocCharge.intInventoryReceiptItemId	
		AND ri.intInventoryReceiptId = r.intInventoryReceiptId
	INNER JOIN tblICItem charge
		ON charge.intItemId = rc.intChargeId
	INNER JOIN tblICItem item
		ON item.intItemId = ri.intItemId
	INNER JOIN #tmpRebuildList list	
		ON item.intItemId = COALESCE(list.intItemId, item.intItemId)
		AND item.intCategoryId = COALESCE(list.intCategoryId, item.intCategoryId)
	INNER JOIN tblICItemLocation il
		ON il.intItemId = item.intItemId
		AND il.intLocationId = r.intLocationId
	CROSS APPLY dbo.fnGetItemGLAccountAsTable (
		item.intItemId
		,il.intItemLocationId 
		,'Inventory'
	) expectedGLInventoryAccount	
	
	CROSS APPLY (
		SELECT
			gd.intGLDetailId
		FROM 
			tblGLDetail gd INNER JOIN tblGLAccount ga 
				ON gd.intAccountId = ga.intAccountId
			INNER JOIN tblGLAccountSegmentMapping gs
				ON gs.intAccountId = ga.intAccountId
			INNER JOIN tblGLAccountSegment gm 
				ON gm.intAccountSegmentId = gs.intAccountSegmentId
			INNER JOIN tblGLAccountCategory ac 
				ON ac.intAccountCategoryId = gm.intAccountCategoryId 
			INNER JOIN tblGLAccountStructure gst 
				ON gm.intAccountStructureId = gst.intAccountStructureId
				and gst.strType = 'Primary'
		WHERE
			gd.strTransactionId = r.strReceiptNumber
			AND gd.intJournalLineNo = allocCharge.intInventoryReceiptItemId
			AND gd.strDescription LIKE '%Charges from ' + charge.strItemNo + ' for ' + item.strItemNo 
			AND ac.strAccountCategory IN ('Inventory')
			AND gd.intAccountId <> expectedGLInventoryAccount.intAccountId
	) gd 
	INNER JOIN tblGLDetail affectedGd
		ON affectedGd.intGLDetailId = gd.intGLDetailId	
WHERE
	(r.strReceiptNumber = @strReceiptNumber OR @strReceiptNumber IS NULL) 
	AND r.dtmReceiptDate >= @dtmDate
	
