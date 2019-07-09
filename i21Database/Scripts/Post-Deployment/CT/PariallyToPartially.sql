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
Print 'END Update pricing status from Parially Priced to Partially Priced'