﻿CREATE PROCEDURE [dbo].[uspQMImportValidationCatalogue]
(
	@intImportLogId INT
)
AS
BEGIN TRY

	BEGIN TRANSACTION

	/** Title: Validation for Tasting Score (Auction/Non-Auction). 
	  * Description: Skip Row when there's no Sample/Catalogue Import found which can be trigger with the combination of these columns below: 
	  *	- Sale Year 
	  *	- Buying Center 
	  *	- Sale No 
	  *	- Catalogue Type 
	  *	- Supplier 
	  *	- Channel
	  *	- Lot No  
	  * JIRA: QC-1006
	**/

	/* Catalogue Validation. */
	UPDATE Catalogue 
	SET Catalogue.strLogResult	= 'Catalogue information is not available for the combination of Sale Year, Buying Center, Sale No, Catalogue Type, Supplier, Channel'
	  , Catalogue.ysnSuccess	= 0
	  , Catalogue.ysnProcessed	= 1
	FROM tblQMImportCatalogue AS Catalogue
	LEFT JOIN (SELECT SaleYear.strSaleYear
				 , CompanyLocation.strLocationName	AS strBuyingCenter
				 , QSample.strSaleNumber			
				 , CatalogueType.strCatalogueType	AS strCatalogueType
				 , Supplier.strName					AS strSupplier
				 , MarketZone.strMarketZoneCode		AS strChannel
				 , QSample.strRepresentLotNumber	AS strLotNumber
				 , QSample.intSampleId
			FROM tblQMSample AS QSample
			LEFT JOIN tblQMSaleYear AS SaleYear ON QSample.intSaleYearId = SaleYear.intSaleYearId
			LEFT JOIN tblSMCompanyLocation AS CompanyLocation ON QSample.intCompanyLocationId = CompanyLocation.intCompanyLocationId
			LEFT JOIN tblQMCatalogueType AS CatalogueType ON QSample.intCatalogueTypeId = CatalogueType.intCatalogueTypeId
			LEFT JOIN tblAPVendor AS Vendor ON QSample.intEntityId = Vendor.intEntityId
			LEFT JOIN tblEMEntity AS Supplier ON QSample.intEntityId = Supplier.intEntityId AND Supplier.intEntityId = Vendor.intEntityId
			LEFT JOIN tblARMarketZone AS MarketZone ON QSample.intMarketZoneId = MarketZone.intMarketZoneId
			) AS QualitySample ON Catalogue.strSaleYear		= QualitySample.strSaleYear
							  AND Catalogue.strBuyingCenter = QualitySample.strBuyingCenter	
							  AND Catalogue.strSaleNumber	= QualitySample.strSaleNumber	
							  AND Catalogue.strCatalogueType = QualitySample.strCatalogueType	
							  AND Catalogue.strSupplier		= QualitySample.strSupplier	
							  AND Catalogue.strChannel		= QualitySample.strChannel	
							  AND Catalogue.strLotNumber	= QualitySample.strLotNumber	
	WHERE Catalogue.intImportLogId = @intImportLogId
	  AND ISNULL(Catalogue.strBatchNo, '') = ''
	  AND Catalogue.ysnSuccess = 1
	  AND QualitySample.intSampleId IS NULL;
    /* End of Catalogue Validation.*/

	COMMIT TRANSACTION
END TRY

BEGIN CATCH
	DECLARE @strErrorMsg NVARCHAR(MAX) = NULL;

	SET @strErrorMsg = ERROR_MESSAGE();

	RAISERROR 
	(
		@strErrorMsg
      , 11
      , 1
	);
END CATCH