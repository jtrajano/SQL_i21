CREATE PROCEDURE [dbo].[uspICFixOtherChargeGLEntries]
	@strReceiptNumber AS NVARCHAR(50) 
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS ON

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
	CROSS APPLY (
		SELECT
			gd.*
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
	) gd 

	INNER JOIN tblGLDetail affectedGd
		ON affectedGd.intGLDetailId = gd.intGLDetailId
	INNER JOIN tblICItemLocation il
		ON il.intItemId = item.intItemId
		AND il.intLocationId = r.intLocationId
	OUTER APPLY dbo.fnGetItemGLAccountAsTable (
		item.intItemId
		,il.intItemLocationId 
		,'Inventory'
	) expectedGLInventoryAccount
WHERE
	r.strReceiptNumber = @strReceiptNumber
	AND gd.intAccountId <> expectedGLInventoryAccount.intAccountId
