CREATE VIEW [dbo].[vyuEMETExportCustomerTaxExemption]  
 AS  
SELECT 
CustomerNumber	
,ItemNumber		
,State			
,Authority1		
,Authority2		= ''	
,FETCharge		= CASE WHEN SUM(ISNULL(FETCharge,0)) > 0 THEN 'Y' ELSE 'N' END
,SETCharge		= CASE WHEN SUM(ISNULL(SETCharge,0)) > 0 THEN 'Y' ELSE 'N' END
,SSTCharge		= CASE WHEN SUM(ISNULL(SSTCharge,0)) > 0 THEN 'Y' ELSE 'N' END
,Locale1Charge	= CASE WHEN SUM(ISNULL(Locale1Charge,0)) > 0 THEN 'Y' ELSE 'N' END
,Locale2Charge	= CASE WHEN SUM(ISNULL(Locale2Charge,0)) > 0 THEN 'Y' ELSE 'N' END
,Locale3Charge	= CASE WHEN SUM(ISNULL(Locale3Charge,0)) > 0 THEN 'Y' ELSE 'N' END
,Locale4Charge	= CASE WHEN SUM(ISNULL(Locale4Charge,0)) > 0 THEN 'Y' ELSE 'N' END
,Locale5Charge	= CASE WHEN SUM(ISNULL(Locale5Charge,0)) > 0 THEN 'Y' ELSE 'N' END
,Locale6Charge	= CASE WHEN SUM(ISNULL(Locale6Charge,0)) > 0 THEN 'Y' ELSE 'N' END
--,intTaxCodeId -- debug
--,strTaxCodeReference -- debug
--,strExemptionNotes-- debug
FROM (
	/************************************************************************************************************************************/
	SELECT 
	intEntityCustomerId
	,CustomerItemsTaxGroupTaxCodes.CustomerNumber
	,CustomerItemsTaxGroupTaxCodes.ItemNumber
	,Authority1 
	,Authority2 = ''
	,intTaxCodeId
	,strTaxGroup 
	,strTaxCodeReference 
	,State
	,FETCharge = (CASE WHEN strTaxCodeReference = 'FET' THEN 
	~(SELECT TOP 1 ysnTaxExempt FROM dbo.fnGetCustomerTaxCodeExemptionDetails(intEntityCustomerId
												,GETDATE()--@TransactionDate			DATETIME
												,intTaxGroupId --NULL --TGC.intTaxGroupId--@TaxGroupId				INT
												,intTaxCodeId
												,intTaxClassId--TC.intTaxClassId --@TaxClassId				INT
												,strState--NULL --@TaxState					NVARCHAR(100)
												,intItemId--NULL --@ItemId					INT
												,intCategoryId --@ItemCategoryId			INT
												,NULL --@ShipToLocationId			INT
												,NULL --@IsCustomerSiteTaxable		BIT
												,NULL --@CardId					INT
												,NULL --@VehicleId					INT
												,NULL --@SiteId					INT
												,NULL --@DisregardExemptionSetup	BIT
												,NULL --@CompanyLocationId			INT
												,NULL --@FreightTermId				INT
												,NULL --@CFSiteId					INT
												,NULL --@IsDeliver					BIT
												,NULL --@IsCFQuote					BIT)
											) 
											)
	ELSE 0 END) 
	,SETCharge = (CASE WHEN strTaxCodeReference = 'SET' THEN 
			~(SELECT TOP 1 ysnTaxExempt FROM dbo.fnGetCustomerTaxCodeExemptionDetails(intEntityCustomerId
												,GETDATE()--@TransactionDate			DATETIME
												,intTaxGroupId --NULL --TGC.intTaxGroupId--@TaxGroupId				INT
												,intTaxCodeId
												,intTaxClassId --@TaxClassId				INT
												,strState--NULL --@TaxState					NVARCHAR(100)
												,intItemId--NULL --@ItemId					INT
												,intCategoryId--NULL --@ItemCategoryId			INT
												,NULL --@ShipToLocationId			INT
												,NULL --@IsCustomerSiteTaxable		BIT
												,NULL --@CardId					INT
												,NULL --@VehicleId					INT
												,NULL --@SiteId					INT
												,NULL --@DisregardExemptionSetup	BIT
												,NULL --@CompanyLocationId			INT
												,NULL --@FreightTermId				INT
												,NULL --@CFSiteId					INT
												,NULL --@IsDeliver					BIT
												,NULL --@IsCFQuote					BIT)
											) 
											)
			ELSE 0  END)--1 means charge
	,SSTCharge = (CASE WHEN strTaxCodeReference = 'SST' THEN 
		~(SELECT TOP 1 ysnTaxExempt FROM dbo.fnGetCustomerTaxCodeExemptionDetails(intEntityCustomerId
												,GETDATE()--@TransactionDate			DATETIME
												,intTaxGroupId --NULL --TGC.intTaxGroupId--@TaxGroupId				INT
												,intTaxCodeId
												,intTaxClassId --TC.intTaxClassId --@TaxClassId				INT
												,strState--NULL --@TaxState					NVARCHAR(100)
												,intItemId--NULL --@ItemId					INT
												,NULL --@ItemCategoryId			INT
												,NULL --@ShipToLocationId			INT
												,NULL --@IsCustomerSiteTaxable		BIT
												,NULL --@CardId					INT
												,NULL --@VehicleId					INT
												,NULL --@SiteId					INT
												,NULL --@DisregardExemptionSetup	BIT
												,NULL --@CompanyLocationId			INT
												,NULL --@FreightTermId				INT
												,NULL --@CFSiteId					INT
												,NULL --@IsDeliver					BIT
												,NULL --@IsCFQuote					BIT)
											) 
											)
		ELSE 0 END)
	,Locale1Charge = (CASE WHEN strTaxCodeReference = 'LC1' THEN 
		~(SELECT TOP 1 ysnTaxExempt FROM dbo.fnGetCustomerTaxCodeExemptionDetails(intEntityCustomerId
												,GETDATE()--@TransactionDate			DATETIME
												,intTaxGroupId --NULL --TGC.intTaxGroupId--@TaxGroupId				INT
												,intTaxCodeId
												,intTaxClassId --TC.intTaxClassId --@TaxClassId				INT
												,strState--NULL --@TaxState					NVARCHAR(100)
												,intItemId--NULL --@ItemId					INT
												,intCategoryId--NULL --@ItemCategoryId			INT
												,NULL --@ShipToLocationId			INT
												,NULL --@IsCustomerSiteTaxable		BIT
												,NULL --@CardId					INT
												,NULL --@VehicleId					INT
												,NULL --@SiteId					INT
												,NULL --@DisregardExemptionSetup	BIT
												,NULL --@CompanyLocationId			INT
												,NULL --@FreightTermId				INT
												,NULL --@CFSiteId					INT
												,NULL --@IsDeliver					BIT
												,NULL --@IsCFQuote					BIT)
											) 
											)
		ELSE 0 END)
	,Locale2Charge = (CASE WHEN strTaxCodeReference = 'LC2' THEN 
			~(SELECT TOP 1 ysnTaxExempt FROM dbo.fnGetCustomerTaxCodeExemptionDetails(intEntityCustomerId
												,GETDATE()--@TransactionDate			DATETIME
												,intTaxGroupId --NULL --TGC.intTaxGroupId--@TaxGroupId				INT
												,intTaxCodeId
												,intTaxClassId --TC.intTaxClassId --@TaxClassId				INT
												,strState--NULL --@TaxState					NVARCHAR(100)
												,intItemId--NULL --@ItemId					INT
												,intCategoryId--NULL --@ItemCategoryId			INT
												,NULL --@ShipToLocationId			INT
												,NULL --@IsCustomerSiteTaxable		BIT
												,NULL --@CardId					INT
												,NULL --@VehicleId					INT
												,NULL --@SiteId					INT
												,NULL --@DisregardExemptionSetup	BIT
												,NULL --@CompanyLocationId			INT
												,NULL --@FreightTermId				INT
												,NULL --@CFSiteId					INT
												,NULL --@IsDeliver					BIT
												,NULL --@IsCFQuote					BIT)
											) 
											)
			ELSE 0 END)
	,Locale3Charge = (CASE WHEN strTaxCodeReference = 'LC3' THEN 
			~(SELECT TOP 1 ysnTaxExempt FROM dbo.fnGetCustomerTaxCodeExemptionDetails(intEntityCustomerId
												,GETDATE()--@TransactionDate			DATETIME
												,intTaxGroupId --NULL --TGC.intTaxGroupId--@TaxGroupId				INT
												,intTaxCodeId
												,intTaxClassId --TC.intTaxClassId --@TaxClassId				INT
												,strState--NULL --@TaxState					NVARCHAR(100)
												,intItemId--NULL --@ItemId					INT
												,intCategoryId--NULL --@ItemCategoryId			INT
												,NULL --@ShipToLocationId			INT
												,NULL --@IsCustomerSiteTaxable		BIT
												,NULL --@CardId					INT
												,NULL --@VehicleId					INT
												,NULL --@SiteId					INT
												,NULL --@DisregardExemptionSetup	BIT
												,NULL --@CompanyLocationId			INT
												,NULL --@FreightTermId				INT
												,NULL --@CFSiteId					INT
												,NULL --@IsDeliver					BIT
												,NULL --@IsCFQuote					BIT)
											) 
											)
		 ELSE 0 END)
	,Locale4Charge = (CASE WHEN strTaxCodeReference = 'LC4' THEN 
		~(SELECT TOP 1 ysnTaxExempt FROM dbo.fnGetCustomerTaxCodeExemptionDetails(intEntityCustomerId
												,GETDATE()--@TransactionDate			DATETIME
												,intTaxGroupId --NULL --TGC.intTaxGroupId--@TaxGroupId				INT
												,intTaxCodeId
												,intTaxClassId --TC.intTaxClassId --@TaxClassId				INT
												,strState--NULL --@TaxState					NVARCHAR(100)
												,intItemId--NULL --@ItemId					INT
												,intCategoryId--NULL --@ItemCategoryId			INT
												,NULL --@ShipToLocationId			INT
												,NULL --@IsCustomerSiteTaxable		BIT
												,NULL --@CardId					INT
												,NULL --@VehicleId					INT
												,NULL --@SiteId					INT
												,NULL --@DisregardExemptionSetup	BIT
												,NULL --@CompanyLocationId			INT
												,NULL --@FreightTermId				INT
												,NULL --@CFSiteId					INT
												,NULL --@IsDeliver					BIT
												,NULL --@IsCFQuote					BIT)
											) 
											)
	ELSE 0 END)
	,Locale5Charge = (CASE WHEN strTaxCodeReference = 'LC5' THEN 
		~(SELECT TOP 1 ysnTaxExempt FROM dbo.fnGetCustomerTaxCodeExemptionDetails(intEntityCustomerId
												,GETDATE()--@TransactionDate			DATETIME
												,intTaxGroupId --NULL --TGC.intTaxGroupId--@TaxGroupId				INT
												,intTaxCodeId
												,intTaxClassId --TC.intTaxClassId --@TaxClassId				INT
												,strState--NULL --@TaxState					NVARCHAR(100)
												,intItemId--NULL --@ItemId					INT
												,intCategoryId--NULL --@ItemCategoryId			INT
												,NULL --@ShipToLocationId			INT
												,NULL --@IsCustomerSiteTaxable		BIT
												,NULL --@CardId					INT
												,NULL --@VehicleId					INT
												,NULL --@SiteId					INT
												,NULL --@DisregardExemptionSetup	BIT
												,NULL --@CompanyLocationId			INT
												,NULL --@FreightTermId				INT
												,NULL --@CFSiteId					INT
												,NULL --@IsDeliver					BIT
												,NULL --@IsCFQuote					BIT)
											) 
											)
		ELSE 0 END)
	,Locale6Charge = (CASE WHEN strTaxCodeReference = 'LC6' THEN 
	~(SELECT TOP 1 ysnTaxExempt FROM dbo.fnGetCustomerTaxCodeExemptionDetails(intEntityCustomerId
												,GETDATE()--@TransactionDate			DATETIME
												,intTaxGroupId --NULL --TGC.intTaxGroupId--@TaxGroupId				INT
												,intTaxCodeId
												,intTaxClassId --TC.intTaxClassId --@TaxClassId				INT
												,strState--NULL --@TaxState					NVARCHAR(100)
												,intItemId--NULL --@ItemId					INT
												,intCategoryId--NULL --@ItemCategoryId			INT
												,NULL --@ShipToLocationId			INT
												,NULL --@IsCustomerSiteTaxable		BIT
												,NULL --@CardId					INT
												,NULL --@VehicleId					INT
												,NULL --@SiteId					INT
												,NULL --@DisregardExemptionSetup	BIT
												,NULL --@CompanyLocationId			INT
												,NULL --@FreightTermId				INT
												,NULL --@CFSiteId					INT
												,NULL --@IsDeliver					BIT
												,NULL --@IsCFQuote					BIT)
											) 
											)
	ELSE 0 END)

			 FROM (
					SELECT DISTINCT Exemp.[intEntityCustomerId] intEntityCustomerId
									,CustomerNumber = strCustomerNumber 
									,ETItems.intItemId
									,ETItems.strItemNo ItemNumber
									,ETItems.intCategoryId
									,Authority1 = ETTaxGroupCode.intTaxGroupId 
									,Authority2 = ''
									,ETTaxGroupCode.intTaxCodeId
									,ETTaxGroupCode.intTaxGroupId
									,ETTaxGroupCode.strTaxGroup 
									,ETTaxGroupCode.intTaxClassId
									,strTaxCodeReference = ETTaxGroupCode.strTaxCodeReference 
									,Substring(ETTaxGroupCode.strTaxGroup, 1, 2) State
									,ETTaxGroupCode.strState
							
					FROM (select DISTINCT intEntityCustomerId from [tblARCustomerTaxingTaxException]) Exemp
					INNER JOIN tblARCustomer ARC ON Exemp.intEntityCustomerId = ARC.intEntityId 
					INNER JOIN tblEMEntityLocation EMEL ON ARC.intEntityId = EMEL.intEntityId AND EMEL.ysnDefaultLocation = 1
					LEFT OUTER JOIN tblSMCompanyLocation SMCL ON EMEL.intWarehouseId = SMCL.intCompanyLocationId

					--INNER JOIN [tblARCustomerTaxingTaxException] ExemptionTaxCode ON Exemp.intCustomerTaxingTaxExceptionId = ExemptionTaxCode.intCustomerTaxingTaxExceptionId 
					--SELECT intEntityId,strCustomerNumber,ETItems.intItemId,ETItems.strItemNo FROM tblARCustomer ARC 
					CROSS APPLY (
					SELECT Distinct intItemId			 
									,strItemNo 
									,intCategoryId
					FROM
					[vyuICETExportItem]
					) ETItems

					CROSS APPLY(
						SELECT DISTINCT TGC.intTaxGroupId,TGC.[intTaxCodeId] ,TaxGroup.strTaxGroup, ETTC.strTaxCodeReference ,TaxCode.strState , TaxCode.intTaxClassId FROM tblSMTaxGroupCode TGC --ON TC.[intTaxCodeId] = TGC.[intTaxCodeId]  AND TGC.intTaxGroupId = @intTaxGroupId
						INNER JOIN tblSMTaxCode TaxCode ON TGC.intTaxCodeId = TaxCode.intTaxCodeId
						INNER JOIN tblICCategoryTax CatTax ON TaxCode.intTaxClassId =  CatTax.intTaxClassId AND CatTax.intCategoryId = ETItems.intCategoryId
						INNER JOIN tblSMTaxGroup TaxGroup ON TGC.intTaxGroupId =  TaxGroup.intTaxGroupId	        
						INNER JOIN (SELECT DISTINCT intTaxCodeId,strTaxCodeReference FROM tblETExportTaxCodeMapping) ETTC ON TGC.intTaxCodeId = ETTC.intTaxCodeId  
						INNER JOIN tblETExportFilterTaxGroup ETTG ON TGC.intTaxGroupId = ETTG.intTaxGroupId
					) ETTaxGroupCode
			) CustomerItemsTaxGroupTaxCodes
		
/************************************************************************************************************************************/
) A

GROUP BY 
	intEntityCustomerId
	,CustomerNumber
	,ItemNumber
	,State	
	,Authority1
	,Authority2
	--,intTaxCodeId -- debug
	--,strTaxCodeReference -- debug
	--,strExemptionNotes -- debug