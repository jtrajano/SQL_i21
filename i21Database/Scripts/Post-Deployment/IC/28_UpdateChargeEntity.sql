PRINT N'BEGIN - Update Charge Entity from tblICInventoryReceiptCharge'
IF EXISTS(SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE [TABLE_NAME] = N'tblICInventoryReceiptCharge' AND [COLUMN_NAME] = N'ysnPrice')
BEGIN
	EXEC('
			UPDATE tblICInventoryReceiptCharge
			SET strChargeEntity = ''Reduce''
			WHERE ysnPrice = 1;
	');
	EXEC('
			UPDATE tblICInventoryReceiptCharge
			SET strChargeEntity = ''No''
			WHERE ysnPrice = 0 OR ysnPrice IS NULL;
	');
END
PRINT N'END - Update Charge Entity from tblICInventoryReceiptCharge'