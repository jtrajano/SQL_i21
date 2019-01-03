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



IF(@upgradebaseversion = '18.3' AND @currentbaseversion = '18.1')
BEGIN
	
	PRINT '*******************BEGIN CARD FUELING 18.1 TO 18.3 DATA CONVERTION*****************'
	PRINT '****' + @currentversion + ' to ' + @upgradeversion + '****'

	--CF-1124
	UPDATE tblCFTransaction
	SET
	dblCalculatedGrossPrice		= dblCalculatedAmount
	,dblOriginalGrossPrice		= dblOriginalAmount
	FROM tblCFTransactionPrice as price
	WHERE price.intTransactionId = tblCFTransaction.intTransactionId
	AND price.strTransactionPriceId = 'Gross Price'

	UPDATE tblCFTransaction
	SET
	dblCalculatedNetPrice		= dblCalculatedAmount
	,dblOriginalNetPrice		= dblOriginalAmount
	FROM tblCFTransactionPrice as price
	WHERE price.intTransactionId = tblCFTransaction.intTransactionId
	AND price.strTransactionPriceId = 'Net Price'

	UPDATE tblCFTransaction
	SET
	dblCalculatedTotalPrice		= dblCalculatedAmount
	,dblOriginalTotalPrice		= dblOriginalAmount
	FROM tblCFTransactionPrice as price
	WHERE price.intTransactionId = tblCFTransaction.intTransactionId
	AND price.strTransactionPriceId = 'Total Amount'

	UPDATE tblCFTransaction
	SET
	dblCalculatedTotalTax		= (SELECT 
	SUM(ISNULL(dblTaxCalculatedAmount,0))
	FROM tblCFTransactionTax as tax
	WHERE tax.intTransactionId = tblCFTransaction.intTransactionId
	GROUP BY tax.intTransactionId)
	,dblOriginalTotalTax		= (SELECT 
	SUM(ISNULL(dblTaxOriginalAmount,0))
	FROM tblCFTransactionTax as tax
	WHERE tax.intTransactionId = tblCFTransaction.intTransactionId
	GROUP BY tax.intTransactionId)
	--CF-1124










	PRINT '*******************END CARD FUELING 18.1 TO 18.3 DATA CONVERTION*****************'
END

