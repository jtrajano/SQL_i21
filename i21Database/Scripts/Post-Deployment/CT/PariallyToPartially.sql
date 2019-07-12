Print 'BEGIN Update pricing status from Parially Priced to Partially Priced'
IF EXISTS(SELECT strPricingStatus FROM tblCTContractBalance WHERE strPricingStatus = 'Parially Priced')
BEGIN
  UPDATE tblCTContractBalance set strPricingStatus = 'Partially Priced' WHERE strPricingStatus = 'Parially Priced'
END
GO

IF EXISTS(SELECT strPricingStatus FROM tblCTSequenceHistory where strPricingStatus = 'Parially Priced')
BEGIN
	UPDATE tblCTSequenceHistory set strPricingStatus = 'Partially Priced' WHERE strPricingStatus = 'Parially Priced'
END
GO

IF EXISTS(SELECT strPriOrNotPriOrParPriced FROM tblRKM2MInquiryTransaction where strPriOrNotPriOrParPriced = 'Parially Priced')
BEGIN
	UPDATE tblRKM2MInquiryTransaction set strPriOrNotPriOrParPriced = 'Partially Priced' WHERE strPriOrNotPriOrParPriced = 'Parially Priced'
END
GO
Print 'END Update pricing status from Parially Priced to Partially Priced'