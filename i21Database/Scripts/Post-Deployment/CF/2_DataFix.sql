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