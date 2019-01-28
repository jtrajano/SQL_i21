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


