--tblCTBuySell
GO
IF NOT EXISTS(SELECT * FROM tblCTBuySell WHERE intBuySellId = 1)
BEGIN
	INSERT INTO tblCTBuySell
	SELECT 1,'Buy',1
END
GO

GO
IF NOT EXISTS(SELECT * FROM tblCTBuySell WHERE intBuySellId = 2)
BEGIN
	INSERT INTO tblCTBuySell
	SELECT 2,'Sell',1	
END
GO

--tblCTPriceCalculationType
GO
IF NOT EXISTS(SELECT * FROM tblCTPriceCalculationType WHERE intPriceCalculationTypeId = 1)
BEGIN
	INSERT INTO tblCTPriceCalculationType
	SELECT 1,'Cash',1	
END
GO

GO
IF NOT EXISTS(SELECT * FROM tblCTPriceCalculationType WHERE intPriceCalculationTypeId = 2)
BEGIN
	INSERT INTO tblCTPriceCalculationType
	SELECT 2,'Futures',1	
END
GO

GO
IF NOT EXISTS(SELECT * FROM tblCTPriceCalculationType WHERE intPriceCalculationTypeId = 3)
BEGIN
	INSERT INTO tblCTPriceCalculationType
	SELECT 3,'Either',1	
END
GO

--tblCTCostMethod
GO
IF NOT EXISTS(SELECT * FROM tblCTCostMethod WHERE intCostMethodId = 1)
BEGIN
	INSERT INTO tblCTCostMethod
	SELECT 1,'Per Unit',1	
END
GO

GO
IF NOT EXISTS(SELECT * FROM tblCTCostMethod WHERE intCostMethodId = 2)
BEGIN
	INSERT INTO tblCTCostMethod
	SELECT 2,'%',1	
END
GO

GO
IF NOT EXISTS(SELECT * FROM tblCTCostMethod WHERE intCostMethodId = 3)
BEGIN
	INSERT INTO tblCTCostMethod
	SELECT 3,'Amount',1	
END
GO

--tblCTPremFee
GO
IF NOT EXISTS(SELECT * FROM tblCTPremFee WHERE intPremFeeId = 1)
BEGIN
	INSERT INTO tblCTPremFee
	SELECT 1,'Bill to Customer',1	
END
GO

GO
IF NOT EXISTS(SELECT * FROM tblCTPremFee WHERE intPremFeeId = 2)
BEGIN
	INSERT INTO tblCTPremFee
	SELECT 2,'Deduct from settlement',1	
END
GO

--tblCTPricingType
GO
IF NOT EXISTS(SELECT * FROM tblCTPricingType WHERE intPricingTypeId = 1)
BEGIN
	INSERT INTO tblCTPricingType
	SELECT 1,'Priced',1	
END
GO

GO
IF NOT EXISTS(SELECT * FROM tblCTPricingType WHERE intPricingTypeId = 2)
BEGIN
	INSERT INTO tblCTPricingType
	SELECT 2,'Basis',1	
END
GO

GO
IF NOT EXISTS(SELECT * FROM tblCTPricingType WHERE intPricingTypeId = 3)
BEGIN
	INSERT INTO tblCTPricingType
	SELECT 3,'HTA',1	
END
GO

GO
IF NOT EXISTS(SELECT * FROM tblCTPricingType WHERE intPricingTypeId = 4)
BEGIN
	INSERT INTO tblCTPricingType
	SELECT 4,'TBD',1	
END
GO

GO
IF NOT EXISTS(SELECT * FROM tblCTPricingType WHERE intPricingTypeId = 5)
BEGIN
	INSERT INTO tblCTPricingType
	SELECT 5,'DP (Priced Later)',1	
END
ELSE
BEGIN
	UPDATE tblCTPricingType SET strPricingType = 'DP (Priced Later)' WHERE intPricingTypeId = 5
END
GO

--tblCTPutCall
GO
IF NOT EXISTS(SELECT * FROM tblCTPutCall WHERE intPutCallId = 1)
BEGIN
	INSERT INTO tblCTPutCall
	SELECT 1,'Put',1	
END
GO

GO
IF NOT EXISTS(SELECT * FROM tblCTPutCall WHERE intPutCallId = 2)
BEGIN
	INSERT INTO tblCTPutCall
	SELECT 2,'Call',1	
END
GO

--tblCTRailGrade
GO
IF NOT EXISTS(SELECT * FROM tblCTRailGrade WHERE intRailGradeId = 1)
BEGIN
	INSERT INTO tblCTRailGrade
	SELECT 1,'Average',1	
END
GO

GO
IF NOT EXISTS(SELECT * FROM tblCTRailGrade WHERE intRailGradeId = 2)
BEGIN
	INSERT INTO tblCTRailGrade
	SELECT 2,'Car',1	
END
GO

--tblCTDiscountType
GO
IF NOT EXISTS(SELECT * FROM tblCTDiscountType WHERE intDiscountTypeId = 1)
BEGIN
	INSERT INTO tblCTDiscountType
	SELECT 1,'Deliver',1	
END
GO

GO
IF NOT EXISTS(SELECT * FROM tblCTDiscountType WHERE intDiscountTypeId = 2)
BEGIN
	INSERT INTO tblCTDiscountType
	SELECT 2,'As-Is',1	
END
GO

GO
IF NOT EXISTS(SELECT * FROM tblCTDiscountType WHERE intDiscountTypeId = 3)
BEGIN
	INSERT INTO tblCTDiscountType
	SELECT 3,'Contract',1	
END
GO

--tblCTDiscount
GO
IF NOT EXISTS(SELECT * FROM tblCTContractType WHERE intContractTypeId = 1)
BEGIN
	INSERT INTO tblCTContractType
	SELECT 1,'Purchase',1	
END
GO

GO
IF NOT EXISTS(SELECT * FROM tblCTContractType WHERE intContractTypeId = 2)
BEGIN
	INSERT INTO tblCTContractType
	SELECT 2,'Sale',1	
END
ELSE
BEGIN
	UPDATE tblCTContractType SET strContractType = 'Sale' WHERE intContractTypeId = 2
END
GO

GO
IF EXISTS(SELECT * FROM tblCTContractType WHERE strContractType = 'DP')
BEGIN
	DELETE FROM tblCTContractType WHERE strContractType = 'DP'
END
GO
--GO
--IF NOT EXISTS(SELECT * FROM tblCTContractType WHERE Value = 3)
--BEGIN
--	INSERT INTO tblCTContractType
--	SELECT 3,'DP',1	
--END
--GO

--tblCTInsuranceBy
GO
IF NOT EXISTS(SELECT * FROM tblCTInsuranceBy WHERE intInsuranceById = 1)
BEGIN
	INSERT INTO tblCTInsuranceBy(intInsuranceById,strInsuranceBy,strDescription,ysnDefault,intConcurrencyId)
	SELECT 1,'Buyer','Buyer',1,1
END
GO

GO
IF NOT EXISTS(SELECT * FROM tblCTInsuranceBy WHERE intInsuranceById = 2)
BEGIN
	INSERT INTO tblCTInsuranceBy(intInsuranceById,strInsuranceBy,strDescription,ysnDefault,intConcurrencyId)
	SELECT 2,'Seller','Seller',0,1
END
GO

--tblCTInvoiceType
GO
IF NOT EXISTS(SELECT * FROM tblCTInvoiceType WHERE intInvoiceTypeId = 1)
BEGIN
	INSERT INTO tblCTInvoiceType(intInvoiceTypeId,strInvoiceType,strDescription,ysnDefault,intConcurrencyId)
	SELECT 1,'Received/Delivered Quantity','Received/Delivered Quantity',0,1
END
GO

GO
IF NOT EXISTS(SELECT * FROM tblCTInvoiceType WHERE intInvoiceTypeId = 2)
BEGIN
	INSERT INTO tblCTInvoiceType(intInvoiceTypeId,strInvoiceType,strDescription,ysnDefault,intConcurrencyId)
	SELECT 2,'Shipped Quantity','Shipped Quantity',0,1
END
GO

GO
IF NOT EXISTS(SELECT * FROM tblCTInvoiceType WHERE intInvoiceTypeId = 3)
BEGIN
	INSERT INTO tblCTInvoiceType(intInvoiceTypeId,strInvoiceType,strDescription,ysnDefault,intConcurrencyId)
	SELECT 3,'Standard Quantity','Standard Quantity',1,1
END
GO