﻿--tblCTBuySell
GO
IF NOT EXISTS(SELECT * FROM tblCTBuySell WHERE Value = 1)
BEGIN
	INSERT INTO tblCTBuySell
	SELECT 1,'Buy',1
END
GO

GO
IF NOT EXISTS(SELECT * FROM tblCTBuySell WHERE Value = 2)
BEGIN
	INSERT INTO tblCTBuySell
	SELECT 2,'Sell',1	
END
GO

--tblCTCashOrFuture
GO
IF NOT EXISTS(SELECT * FROM tblCTCashOrFuture WHERE Value = 1)
BEGIN
	INSERT INTO tblCTCashOrFuture
	SELECT 1,'Cash',1	
END
GO

GO
IF NOT EXISTS(SELECT * FROM tblCTCashOrFuture WHERE Value = 2)
BEGIN
	INSERT INTO tblCTCashOrFuture
	SELECT 2,'Futures',1	
END
GO

GO
IF NOT EXISTS(SELECT * FROM tblCTCashOrFuture WHERE Value = 3)
BEGIN
	INSERT INTO tblCTCashOrFuture
	SELECT 3,'Either',1	
END
GO

--tblCTCostMethod
GO
IF NOT EXISTS(SELECT * FROM tblCTCostMethod WHERE Value = 1)
BEGIN
	INSERT INTO tblCTCostMethod
	SELECT 1,'Per Unit',1	
END
GO

GO
IF NOT EXISTS(SELECT * FROM tblCTCostMethod WHERE Value = 2)
BEGIN
	INSERT INTO tblCTCostMethod
	SELECT 2,'%',1	
END
GO

GO
IF NOT EXISTS(SELECT * FROM tblCTCostMethod WHERE Value = 3)
BEGIN
	INSERT INTO tblCTCostMethod
	SELECT 3,'Amount',1	
END
GO

--tblCTPremFee
GO
IF NOT EXISTS(SELECT * FROM tblCTPremFee WHERE Value = 1)
BEGIN
	INSERT INTO tblCTPremFee
	SELECT 1,'Bill to Customer',1	
END
GO

GO
IF NOT EXISTS(SELECT * FROM tblCTPremFee WHERE Value = 2)
BEGIN
	INSERT INTO tblCTPremFee
	SELECT 2,'Deduct from settlement',1	
END
GO

--tblCTPricingType
GO
IF NOT EXISTS(SELECT * FROM tblCTPricingType WHERE Value = 1)
BEGIN
	INSERT INTO tblCTPricingType
	SELECT 1,'Priced',1	
END
GO

GO
IF NOT EXISTS(SELECT * FROM tblCTPricingType WHERE Value = 2)
BEGIN
	INSERT INTO tblCTPricingType
	SELECT 2,'Basis',1	
END
GO

GO
IF NOT EXISTS(SELECT * FROM tblCTPricingType WHERE Value = 3)
BEGIN
	INSERT INTO tblCTPricingType
	SELECT 3,'HTA',1	
END
GO

GO
IF NOT EXISTS(SELECT * FROM tblCTPricingType WHERE Value = 4)
BEGIN
	INSERT INTO tblCTPricingType
	SELECT 4,'TBD',1	
END
GO

GO
IF NOT EXISTS(SELECT * FROM tblCTPricingType WHERE Value = 5)
BEGIN
	INSERT INTO tblCTPricingType
	SELECT 5,'DP (Priced Later)',1	
END
ELSE
BEGIN
	UPDATE tblCTPricingType SET Name = 'DP (Priced Later)' WHERE Value = 5
END
GO

--tblCTPutCall
GO
IF NOT EXISTS(SELECT * FROM tblCTPutCall WHERE Value = 1)
BEGIN
	INSERT INTO tblCTPutCall
	SELECT 1,'Put',1	
END
GO

GO
IF NOT EXISTS(SELECT * FROM tblCTPutCall WHERE Value = 2)
BEGIN
	INSERT INTO tblCTPutCall
	SELECT 2,'Call',1	
END
GO

--tblCTRailGrade
GO
IF NOT EXISTS(SELECT * FROM tblCTRailGrade WHERE Value = 1)
BEGIN
	INSERT INTO tblCTRailGrade
	SELECT 1,'Average',1	
END
GO

GO
IF NOT EXISTS(SELECT * FROM tblCTRailGrade WHERE Value = 2)
BEGIN
	INSERT INTO tblCTRailGrade
	SELECT 2,'Car',1	
END
GO

--tblCTDiscount
GO
IF NOT EXISTS(SELECT * FROM tblCTDiscount WHERE Value = 1)
BEGIN
	INSERT INTO tblCTDiscount
	SELECT 1,'Deliver',1	
END
GO

GO
IF NOT EXISTS(SELECT * FROM tblCTDiscount WHERE Value = 2)
BEGIN
	INSERT INTO tblCTDiscount
	SELECT 2,'As-Is',1	
END
GO

GO
IF NOT EXISTS(SELECT * FROM tblCTDiscount WHERE Value = 3)
BEGIN
	INSERT INTO tblCTDiscount
	SELECT 3,'Contract',1	
END
GO

--tblCTDiscount
GO
IF NOT EXISTS(SELECT * FROM tblCTContractType WHERE Value = 1)
BEGIN
	INSERT INTO tblCTContractType
	SELECT 1,'Purchase',1	
END
GO

GO
IF NOT EXISTS(SELECT * FROM tblCTContractType WHERE Value = 2)
BEGIN
	INSERT INTO tblCTContractType
	SELECT 2,'Sale',1	
END
ELSE
BEGIN
	UPDATE tblCTContractType SET Name = 'Sale' WHERE Value = 2
END
GO

GO
IF EXISTS(SELECT * FROM tblCTContractType WHERE Name = 'DP')
BEGIN
	DELETE FROM tblCTContractType WHERE Name = 'DP'
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
	INSERT INTO tblCTInsuranceBy(intInsuranceById,strInsuranceBy,strDescription,ysnDefault,intConcurrencyId)
	SELECT 1,'Received/Delivered Quantity','Received/Delivered Quantity',0,1
END
GO

GO
IF NOT EXISTS(SELECT * FROM tblCTInvoiceType WHERE intInvoiceTypeId = 2)
BEGIN
	INSERT INTO tblCTInsuranceBy(intInsuranceById,strInsuranceBy,strDescription,ysnDefault,intConcurrencyId)
	SELECT 2,'Shipped Quantity','Shipped Quantity',0,1
END
GO

GO
IF NOT EXISTS(SELECT * FROM tblCTInvoiceType WHERE intInvoiceTypeId = 3)
BEGIN
	INSERT INTO tblCTInsuranceBy(intInsuranceById,strInsuranceBy,strDescription,ysnDefault,intConcurrencyId)
	SELECT 3,'Standard Quantity','Standard Quantity',1,1
END
GO