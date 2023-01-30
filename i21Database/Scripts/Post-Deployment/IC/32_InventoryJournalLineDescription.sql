-- --------------------------------------------------
-- Script for SQL Server 2005, 2008, and Azure
-- Purpose: Update the Journal Line Description
-- --------------------------------------------------

print('/*******************  BEGIN Populate tblGlDetail.strJournalLineDescription related to Inventory *******************/')
GO

IF EXISTS (SELECT TOP 1 1 FROM tblICCompanyPreference WHERE ISNULL(ysnUpdateJournalLineDescription, 0) = 0)
BEGIN 

	-- 1. Find the Shipment Taxes
	UPDATE gd
	SET 
		gd.strJournalLineDescription = 'InventoryShipmentChargeTaxId'
	from 
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
		INNER JOIN (
			tblICInventoryShipmentChargeTax tax INNER JOIN tblICInventoryShipmentCharge c
				ON tax.intInventoryShipmentChargeId = c.intInventoryShipmentChargeId
			INNER JOIN tblICInventoryShipment s
				ON s.intInventoryShipmentId = c.intInventoryShipmentId
		)
			ON 
			gd.strTransactionId = s.strShipmentNumber
			AND gd.intTransactionId = s.intInventoryShipmentId
			AND gd.intJournalLineNo = tax.intInventoryShipmentChargeTaxId

	where
		gd.strCode = 'IC'
		AND gst.strType = 'Primary'
		AND ISNULL(gd.dblDebitUnit, 0) = 0 
		AND ISNULL(gd.dblCreditUnit, 0) = 0 

	-- 2. Find the Shipment Other Charges
	UPDATE gd
	SET 
		gd.strJournalLineDescription = 'InventoryShipmentItemId'
	from 
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
		INNER JOIN (
			tblICInventoryShipmentItem shipmentItem 
			INNER JOIN tblICInventoryShipment shipment
				ON shipmentItem.intInventoryShipmentId = shipment.intInventoryShipmentId
		)
			ON 
			gd.strTransactionId = shipment.strShipmentNumber
			AND gd.intTransactionId = shipment.intInventoryShipmentId
			AND gd.intJournalLineNo = shipmentItem.intInventoryShipmentItemId

	where
		gd.strCode = 'IC'
		AND gst.strType = 'Primary'
		AND ISNULL(gd.dblDebitUnit, 0) = 0 
		AND ISNULL(gd.dblCreditUnit, 0) = 0 

	-- 3. Find the Receipt Other Charges
	UPDATE gd
	SET 
		gd.strJournalLineDescription = 'InventoryReceiptItemId'
	from 
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
		INNER JOIN (
			tblICInventoryReceiptItem ri
			INNER JOIN tblICInventoryReceipt r
				ON ri.intInventoryReceiptId = r.intInventoryReceiptId
		)
			ON 
			gd.strTransactionId = r.strReceiptNumber
			AND gd.intTransactionId = r.intInventoryReceiptId
			AND gd.intJournalLineNo = ri.intInventoryReceiptItemId

	where
		gd.strCode = 'IC'
		AND gst.strType = 'Primary'
		AND ISNULL(gd.dblDebitUnit, 0) = 0 
		AND ISNULL(gd.dblCreditUnit, 0) = 0 
		AND gd.strDescription LIKE '%Charges from%'

	-- 4. Find the Receipt Other Charges
	UPDATE gd
	SET 
		gd.strJournalLineDescription = 'InventoryReceiptChargeId'
	from 
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
		INNER JOIN (
			tblICInventoryReceiptCharge rc
			INNER JOIN tblICInventoryReceipt r
				ON rc.intInventoryReceiptId = r.intInventoryReceiptId
		)
			ON 
			gd.strTransactionId = r.strReceiptNumber
			AND gd.intTransactionId = r.intInventoryReceiptId
			AND gd.intJournalLineNo = rc.intInventoryReceiptChargeId

	where
		gd.strCode = 'IC'
		AND gst.strType = 'Primary'
		AND ISNULL(gd.dblDebitUnit, 0) = 0 
		AND ISNULL(gd.dblCreditUnit, 0) = 0 
		AND gd.strDescription LIKE '%Charges from%'

	-- 5. Find the Receipt Taxes (Other Charges)
	UPDATE gd
	SET 
		gd.strJournalLineDescription = 'InventoryReceiptChargeTaxId'
	from 
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
		INNER JOIN (
			tblICInventoryReceiptChargeTax tax INNER JOIN tblICInventoryReceiptCharge c
				ON tax.intInventoryReceiptChargeId = c.intInventoryReceiptChargeId
			INNER JOIN tblICInventoryReceipt r 
				ON r.intInventoryReceiptId = c.intInventoryReceiptId
		)
			ON 
			gd.strTransactionId = r.strReceiptNumber
			AND gd.intTransactionId = r.intInventoryReceiptId
			AND gd.intJournalLineNo = tax.intInventoryReceiptChargeTaxId

	where
		gd.strCode = 'IC'
		AND gst.strType = 'Primary'
		AND ISNULL(gd.dblDebitUnit, 0) = 0 
		AND ISNULL(gd.dblCreditUnit, 0) = 0 

	-- 6. Find the Receipt Taxes (Items)
	UPDATE gd
	SET 
		gd.strJournalLineDescription = 'InventoryReceiptItemTaxId'
	from 
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
		INNER JOIN (
			tblICInventoryReceiptItemTax tax INNER JOIN tblICInventoryReceiptItem ri
				ON tax.intInventoryReceiptItemId = ri.intInventoryReceiptItemId
			INNER JOIN tblICInventoryReceipt r 
				ON r.intInventoryReceiptId = ri.intInventoryReceiptId
		)
			ON 
			gd.strTransactionId = r.strReceiptNumber
			AND gd.intTransactionId = r.intInventoryReceiptId
			AND gd.intJournalLineNo = tax.intInventoryReceiptItemTaxId

	where
		gd.strCode = 'IC'
		AND gst.strType = 'Primary'
		AND ISNULL(gd.dblDebitUnit, 0) = 0 
		AND ISNULL(gd.dblCreditUnit, 0) = 0 

	UPDATE tblICCompanyPreference
	SET ysnUpdateJournalLineDescription = 1 
END

GO
print('/*******************  END Populate tblGlDetail.strJournalLineDescription related to Inventory *******************/')
