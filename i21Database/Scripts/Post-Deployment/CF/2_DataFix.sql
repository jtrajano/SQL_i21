GO 



UPDATE tblCFPriceProfileDetail SET strBasis = 'Remote Index Cost' WHERE strBasis = 'Remote Pricing Index'
UPDATE tblCFPriceProfileDetail SET strBasis = 'Transfer Cost' WHERE strBasis = 'Discounted Price' OR strBasis = 'Transfer Price'
UPDATE tblCFPriceProfileDetail SET strBasis = 'Pump Price Adjustment' WHERE strBasis = 'Full Retail'


UPDATE tblCFTransaction
SET tblCFTransaction.intForDeleteTransId = CAST(REPLACE(strTransactionId,'CFDT-','') AS int)




UPDATE tblCFCompanyPreference set strEnvelopeType = '#10 Envelope' WHERE ISNULL(strEnvelopeType,'') = ''


--CF-1376

UPDATE tblCFTransaction 
SET intCustomerId = (SELECT TOP 1 intCustomerId FROM tblCFNetwork WHERE intNetworkId = tblCFTransaction.intNetworkId)
WHERE strTransactionType = 'Foreign Sale'
AND ISNULL(tblCFTransaction.intCustomerId,0) = 0


UPDATE tblCFTransaction 
SET intCustomerId = (
SELECT TOP 1 cfAccnt.intCustomerId
FROM tblCFCard AS cfCard
INNER JOIN tblCFAccount AS cfAccnt
ON cfCard.intAccountId = cfAccnt.intAccountId
WHERE intCardId = tblCFTransaction.intCardId
)
WHERE strTransactionType != 'Foreign Sale'
AND ISNULL(tblCFTransaction.intCustomerId,0) = 0


 UPDATE tblCFTransaction SET ysnInvoiced = 1 WHERE strInvoiceReportNumber IS NOT NULL



--CF-2122
UPDATE tblCFInvoiceStagingTable SET strStatementType = 'Invoice' WHERE ISNULL(strStatementType,'') = ''
UPDATE tblCFInvoiceReportTempTable SET strStatementType = 'Invoice' WHERE ISNULL(strStatementType,'') = ''
UPDATE tblCFInvoiceSummaryTempTable SET strStatementType = 'Invoice' WHERE ISNULL(strStatementType,'') = ''


--CF-2292
DECLARE @cfDuplicateCardNumber AS INT
SET @cfDuplicateCardNumber = (SELECT COUNT(1) FROM tblCFCard WHERE strCardNumber IN (
		SELECT strCardNumber FROM tblCFCard GROUP BY intNetworkId  , strCardNumber HAVING COUNT(1) > 1 
	))

-- CHECK IF DUPLICATES EXISTS
IF (@cfDuplicateCardNumber <= 0)
BEGIN
	-- CREATE UNIQUE INDEX IF INDEX IS NOT YET EXISTS
	IF NOT EXISTS(SELECT * FROM sys.indexes WHERE name = 'tblCFCard_UniqueNetworkCardNumber' AND object_id = OBJECT_ID('tblCFCard'))
	BEGIN
		--CREATE UNIQUE CONSTRAINTS FOR network , account , card number
		CREATE UNIQUE NONCLUSTERED INDEX [tblCFCard_UniqueNetworkCardNumber]
		ON [dbo].[tblCFCard]([intNetworkId] ASC, [strCardNumber] ASC) WITH (FILLFACTOR = 70);
	END
END


IF EXISTS(SELECT * FROM sys.indexes WHERE name = 'tblCFFactorTaxGroupXRef_UniqueCustomerState' AND object_id = OBJECT_ID('tblCFFactorTaxGroupXRef'))
BEGIN
	DROP INDEX tblCFFactorTaxGroupXRef_UniqueCustomerState ON tblCFFactorTaxGroupXRef;
END


PRINT '[CF-2415] STARTED UPDATING INVOICE CYCLE OF INVOICE HISTORY'

UPDATE tblCFInvoiceHistoryStagingTable
SET intInvoiceCycle = tblCFInvoiceCycle.intInvoiceCycleId
,strInvoiceCycle = tblCFInvoiceCycle.strInvoiceCycle
FROM tblCFAccount
INNER JOIN tblCFInvoiceCycle
ON tblCFAccount.intInvoiceCycle = tblCFInvoiceCycle.intInvoiceCycleId
WHERE tblCFAccount.intAccountId = tblCFInvoiceHistoryStagingTable.intAccountId 
AND ISNULL(tblCFInvoiceHistoryStagingTable.intInvoiceCycle,0) = 0 AND ISNULL(tblCFInvoiceHistoryStagingTable.strInvoiceCycle,'') = ''


PRINT '[CF-2415] ENDED UPDATING INVOICE CYCLE OF INVOICE HISTORY'
