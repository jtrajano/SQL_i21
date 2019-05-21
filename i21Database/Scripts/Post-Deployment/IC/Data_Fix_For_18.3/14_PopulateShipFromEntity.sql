PRINT N'BEGIN - IC Data Fix for 18.3. #14'
GO

IF EXISTS (SELECT TOP 1 1 FROM tblICInventoryReceipt r WHERE r.intShipFromEntityId IS NULL AND r.intEntityVendorId IS NOT NULL)
BEGIN 
	UPDATE r
	SET 
		r.intShipFromEntityId = r.intEntityVendorId		
	FROM 
		tblICInventoryReceipt r
	WHERE
		r.intShipFromEntityId IS NULL
		AND r.intEntityVendorId IS NOT NULL
END 
GO

PRINT N'END - IC Data Fix for 18.3. #14'