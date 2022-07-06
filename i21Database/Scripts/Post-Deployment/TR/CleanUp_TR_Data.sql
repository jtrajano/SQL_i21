GO
	PRINT N'Update blank default Rack Price to Use';
GO

UPDATE tblTRCompanyPreference
SET strRackPriceToUse = 'Vendor'
WHERE ISNULL(strRackPriceToUse, '') = ''

GO


PRINT('Sync Freight-in with Freight-out')
GO

IF EXISTS(SELECT * FROM  INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'tblSMCleanupLog') 
BEGIN
	IF NOT EXISTS(SELECT * FROM  tblSMCleanupLog WHERE strModuleName = 'TR' AND strDesription = 'Sync Freight-In and Freight-Out' AND ysnActive = 1)
	BEGIN
		UPDATE tblARCustomerFreightXRef SET dblFreightRateIn = dblFreightRate WHERE dblFreightRate > 0 AND dblFreightRateIn IS NULL

		INSERT INTO tblSMCleanupLog VALUES('TR', 'Sync Freight-In and Freight-Out', GETDATE(), GETUTCDATE(), 1)
	END
END
GO




