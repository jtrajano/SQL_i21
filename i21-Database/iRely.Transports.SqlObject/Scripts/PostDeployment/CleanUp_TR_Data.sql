GO
	PRINT N'Update blank default Rack Price to Use';
GO

UPDATE tblTRCompanyPreference
SET strRackPriceToUse = 'Vendor'
WHERE ISNULL(strRackPriceToUse, '') = ''

GO