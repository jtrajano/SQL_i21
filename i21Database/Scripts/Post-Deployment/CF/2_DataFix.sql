GO 

--update tblCFPriceProfileDetail set intLocalPricingIndex = null where intLocalPricingIndex = 0
--update tblCFAccount set intPriceRuleGroup = null where intPriceRuleGroup = 0
--update tblCFCard set intCardTypeId = null where intCardTypeId = 0 
--update tblCFIndexPricingBySiteGroupHeader set intPriceIndexId = null where intPriceIndexId = 0


UPDATE tblCFPriceProfileDetail SET strBasis = 'Remote Index Cost' WHERE strBasis = 'Remote Pricing Index'
UPDATE tblCFPriceProfileDetail SET strBasis = 'Transfer Cost' WHERE strBasis = 'Discounted Price'
UPDATE tblCFPriceProfileDetail SET strBasis = 'Pump Price Adjustment' WHERE strBasis = 'Full Retail'


UPDATE tblCFTransaction
SET tblCFTransaction.intForDeleteTransId = CAST(REPLACE(strTransactionId,'CFDT-','') AS int)




UPDATE tblCFCompanyPreference set strEnvelopeType = '#10 Envelope' WHERE ISNULL(strEnvelopeType,'') = ''


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


