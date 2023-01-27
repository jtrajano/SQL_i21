
PRINT N'START - Populate value for tblICInventoryTransaction.dblComputedValue'
GO

IF EXISTS (SELECT TOP 1 1 FROM tblICCompanyPreference WHERE ysnMigrateComputedValueField = 0 OR ysnMigrateComputedValueField IS NULL)
BEGIN 
	UPDATE tblICInventoryTransaction 
	SET	dblComputedValue = dbo.fnMultiply(dblQty, dblCost) + ISNULL(dblValue, 0) 

	UPDATE tblICCompanyPreference
	SET ysnMigrateComputedValueField = 1 
END 

GO 
PRINT N'END - Populate value for tblICInventoryTransaction.dblComputedValue'