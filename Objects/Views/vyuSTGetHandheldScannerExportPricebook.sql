CREATE VIEW [dbo].[vyuSTGetHandheldScannerExportPricebook]
	AS
	
SELECT EP.*
	, HS.intStoreId
	, Store.intCompanyLocationId
FROM tblSTHandheldScannerExportPricebook EP
LEFT JOIN tblSTHandheldScanner HS ON HS.intHandheldScannerId = EP.intHandheldScannerId
LEFT JOIN tblSTStore Store ON Store.intStoreId = HS.intStoreId