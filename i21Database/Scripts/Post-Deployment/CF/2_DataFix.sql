GO 

update tblCFPriceProfileDetail set intLocalPricingIndex = null where intLocalPricingIndex = 0
update tblCFAccount set intPriceRuleGroup = null where intPriceRuleGroup = 0
update tblCFCard set intCardTypeId = null where intCardTypeId = 0 
update tblCFIndexPricingBySiteGroupHeader set intPriceIndexId = null where intPriceIndexId = 0
