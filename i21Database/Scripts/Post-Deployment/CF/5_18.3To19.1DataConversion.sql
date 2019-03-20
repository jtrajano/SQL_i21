GO

DECLARE @currentversionId int
DECLARE @currentversion nvarchar(1000)
DECLARE @currentbaseversion nvarchar(1000)

DECLARE @upgradeversionId int
DECLARE @upgradeversion nvarchar(1000)
DECLARE @upgradebaseversion nvarchar(1000)

select top 1 @upgradeversionId = intVersionID , @upgradeversion = strVersionNo from tblSMBuildNumber order by intVersionID Desc
select top 1 @currentversionId = intVersionID , @currentversion = strVersionNo from tblSMBuildNumber where intVersionID != @upgradeversionId  order by intVersionID Desc


SET @upgradebaseversion = SUBSTRING(LTRIM(RTRIM(@upgradeversion)),0,5)
SET @currentbaseversion = SUBSTRING(LTRIM(RTRIM(@currentversion)),0,5)

PRINT 'find me ***' + @currentversion + '**'  + @upgradeversion



IF(@upgradebaseversion = '19.1' AND @currentbaseversion = '18.3')
BEGIN
	
	PRINT '*******************BEGIN CARD FUELING 18.3 TO 19.1 DATA CONVERTION*****************'
	PRINT '****' + @currentversion + ' to ' + @upgradeversion + '****'


	---CF-2064---
	UPDATE tblCFAccount 
	SET strDetailDisplay = ( CASE 
							WHEN (strPrimarySortOptions = 'Card')
							THEN 'Vehicle'
							WHEN (strPrimarySortOptions = 'Vehicle')
							THEN 'Card'
							WHEN (strPrimarySortOptions = 'Miscellaneous')
							THEN 'Vehicle'
						END)
	

	UPDATE tblCFInvoiceHistoryStagingTable 
	SET 
	strDetailDisplay = (CASE 
							WHEN (strPrimarySortOptions = 'Card')
							THEN 'Vehicle'
							WHEN (strPrimarySortOptions = 'Vehicle')
							THEN 'Card'
							WHEN (strPrimarySortOptions = 'Miscellaneous')
							THEN 'Vehicle'
						END)
	---CF-2064---


	---CF-1755---
	
	--Convert Price Index Type by using Price Profiles to Update Index Type.
	UPDATE tblCFPriceIndex SET strType = 'Cost'
	WHERE intPriceIndexId IN (
	SELECT DISTINCT
	intLocalPricingIndex 
	FROM tblCFPriceProfileDetail 
	WHERE strBasis like '%Index Cost%')

	UPDATE tblCFPriceIndex SET strType = 'Fixed'
	WHERE intPriceIndexId IN (
	SELECT DISTINCT
	intLocalPricingIndex 
	FROM tblCFPriceProfileDetail 
	WHERE strBasis like '%Index Fixed%')

	UPDATE tblCFPriceIndex SET strType = 'Retail'
	WHERE intPriceIndexId IN (
	SELECT DISTINCT
	intLocalPricingIndex 
	FROM tblCFPriceProfileDetail 
	WHERE strBasis like '%Index Retail%')


	--Convert Transactions Price Basis to new Standard Description
	UPDATE tblCFTransaction SET strPriceBasis = 'Index Cost' WHERE strPriceBasis like '%Index Cost%'
	UPDATE tblCFTransaction SET strPriceBasis = 'Index Retail' WHERE strPriceBasis like '%Index Retail%' 
	UPDATE tblCFTransaction SET strPriceBasis = 'Index Fixed' WHERE strPriceBasis like '%Index Fixed%'


	--Convert Price Profiles Price Basis
	UPDATE tblCFPriceProfileDetail set strBasis = 'Index' WHERE strBasis like '%Index%'

	---CF-1755---







	PRINT '*******************END CARD FUELING 18.3 TO 19.1 DATA CONVERTION*****************'
END

