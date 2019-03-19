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
	UPDATE tblCFPriceProfileDetail set strBasis = 'Index' WHERE strBasis IN ('Remote Index Cost','Local Index Retail','Local Index Cost','Local Index Fixed')
	---CF-1755---







	PRINT '*******************END CARD FUELING 18.3 TO 19.1 DATA CONVERTION*****************'
END

