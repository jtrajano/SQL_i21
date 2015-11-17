﻿--tblCTBuySell
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
ELSE
BEGIN
	UPDATE tblCTPricingType SET strPricingType = 'Unit' WHERE intPricingTypeId = 4
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

GO
IF NOT EXISTS(SELECT * FROM tblCTPricingType WHERE intPricingTypeId = 6)
BEGIN
	INSERT INTO tblCTPricingType
	SELECT 6,'Cash',1	
END
GO

GO
IF NOT EXISTS(SELECT * FROM tblCTPricingType WHERE intPricingTypeId = 7)
BEGIN
	INSERT INTO tblCTPricingType
	SELECT 7,'Index',1	
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

--tblCTContractStatus
GO
IF NOT EXISTS(SELECT * FROM tblCTContractStatus WHERE intContractStatusId = 1)
BEGIN
	INSERT INTO tblCTContractStatus(intContractStatusId,strContractStatus,intConcurrencyId)
	SELECT 1,'Open',1	
END
GO

GO
IF NOT EXISTS(SELECT * FROM tblCTContractStatus WHERE intContractStatusId = 2)
BEGIN
	INSERT INTO tblCTContractStatus(intContractStatusId,strContractStatus,intConcurrencyId)
	SELECT 2,'Unconfirmed',1	
END
GO

GO
IF NOT EXISTS(SELECT * FROM tblCTContractStatus WHERE intContractStatusId = 3)
BEGIN
	INSERT INTO tblCTContractStatus(intContractStatusId,strContractStatus,intConcurrencyId)
	SELECT 3,'Cancelled',1	
END
GO

GO
IF NOT EXISTS(SELECT * FROM tblCTContractStatus WHERE intContractStatusId = 4)
BEGIN
	INSERT INTO tblCTContractStatus(intContractStatusId,strContractStatus,intConcurrencyId)
	SELECT 4,'Re-Open',1	
END
GO

GO
IF NOT EXISTS(SELECT * FROM tblCTContractStatus WHERE intContractStatusId = 5)
BEGIN
	INSERT INTO tblCTContractStatus(intContractStatusId,strContractStatus,intConcurrencyId)
	SELECT 5,'Complete',1	
END
GO

GO
IF NOT EXISTS(SELECT * FROM tblCTCleanCostExpenseType)
BEGIN
	INSERT INTO tblCTCleanCostExpenseType(intConcurrencyId,strExpenseName,strExpenseDescription,ysnQuantityEnable)
	SELECT 1,'Profit/Loss','Profit/Loss',0 UNION ALL
	SELECT 1,'Margin Calls','Margin Calls',0 UNION ALL
	SELECT 1,'Credit/Debit Fixations','Credit/Debit Fixations',0 UNION ALL
	SELECT 1,'Franchise/ Reweights','Franchise/ Reweights',1 UNION ALL
	SELECT 1,'Debit Quality','Debit Quality',0 UNION ALL
	SELECT 1,'Refund Insurance (Damage)','Refund Insurance (Damage)',1 
END
GO

-- Inventory Planning Report -- Vinoth
GO
IF NOT EXISTS(SELECT 1 FROM tblCTReportMaster WHERE strReportName = 'Inventory Planning Report')
BEGIN
	INSERT INTO tblCTReportMaster(intReportMasterID,strReportName)
	VALUES(1,'Inventory Planning Report')
END
GO


GO
IF NOT EXISTS(SELECT 1 FROM tblCTReportAttribute WHERE intReportMasterID = 1 AND intReportAttributeID = 1)
BEGIN
	INSERT INTO tblCTReportAttribute(intReportMasterID,intReportAttributeID,strAttributeName)
	VALUES(1,1,'Item and Source of data')
END
GO

GO
IF NOT EXISTS(SELECT 1 FROM tblCTReportAttribute WHERE intReportMasterID = 1 AND intReportAttributeID = 2)
BEGIN
	INSERT INTO tblCTReportAttribute(intReportMasterID,intReportAttributeID,strAttributeName)
	VALUES(1,2,'Opening Inventory')
END
GO

GO
IF NOT EXISTS(SELECT 1 FROM tblCTReportAttribute WHERE intReportMasterID = 1 AND intReportAttributeID = 3)
BEGIN
	INSERT INTO tblCTReportAttribute(intReportMasterID,intReportAttributeID,strAttributeName)
	VALUES(1,3,'Expected Deliveries')
END
GO

GO
IF NOT EXISTS(SELECT 1 FROM tblCTReportAttribute WHERE intReportMasterID = 1 AND intReportAttributeID = 4)
BEGIN
	INSERT INTO tblCTReportAttribute(intReportMasterID,intReportAttributeID,strAttributeName)
	VALUES(1,4,'Existing Purchases')
END
GO

GO
IF NOT EXISTS(SELECT 1 FROM tblCTReportAttribute WHERE intReportMasterID = 1 AND intReportAttributeID = 5)
BEGIN
	INSERT INTO tblCTReportAttribute(intReportMasterID,intReportAttributeID,strAttributeName)
	VALUES(1,5,'Planned Purchases - Bags')
END
GO

GO
IF NOT EXISTS(SELECT 1 FROM tblCTReportAttribute WHERE intReportMasterID = 1 AND intReportAttributeID = 6)
BEGIN
	INSERT INTO tblCTReportAttribute(intReportMasterID,intReportAttributeID,strAttributeName)
	VALUES(1,6,'Planned Purchases - ')
END
GO

GO
IF NOT EXISTS(SELECT 1 FROM tblCTReportAttribute WHERE intReportMasterID = 1 AND intReportAttributeID = 7)
BEGIN
	INSERT INTO tblCTReportAttribute(intReportMasterID,intReportAttributeID,strAttributeName)
	VALUES(1,7,'Total Deliveries')
END
GO

GO
IF NOT EXISTS(SELECT 1 FROM tblCTReportAttribute WHERE intReportMasterID = 1 AND intReportAttributeID = 8)
BEGIN
	INSERT INTO tblCTReportAttribute(intReportMasterID,intReportAttributeID,strAttributeName)
	VALUES(1,8,'Forecasted Consumption')
END
GO

GO
IF NOT EXISTS(SELECT 1 FROM tblCTReportAttribute WHERE intReportMasterID = 1 AND intReportAttributeID = 9)
BEGIN
	INSERT INTO tblCTReportAttribute(intReportMasterID,intReportAttributeID,strAttributeName)
	VALUES(1,9,'Ending Inventory')
END
GO

GO
IF NOT EXISTS(SELECT 1 FROM tblCTReportAttribute WHERE intReportMasterID = 1 AND intReportAttributeID = 10)
BEGIN
	INSERT INTO tblCTReportAttribute(intReportMasterID,intReportAttributeID,strAttributeName)
	VALUES(1,10,'Weeks of Supply')
END
GO

GO
IF NOT EXISTS(SELECT 1 FROM tblCTReportAttribute WHERE intReportMasterID = 1 AND intReportAttributeID = 11)
BEGIN
	INSERT INTO tblCTReportAttribute(intReportMasterID,intReportAttributeID,strAttributeName)
	VALUES(1,11,'Weeks of Supply Target')
END
GO

GO
IF NOT EXISTS(SELECT 1 FROM tblCTReportAttribute WHERE intReportMasterID = 1 AND intReportAttributeID = 12)
BEGIN
	INSERT INTO tblCTReportAttribute(intReportMasterID,intReportAttributeID,strAttributeName)
	VALUES(1,12,'Short/Excess Inventory')
END
GO

GO
IF NOT EXISTS(SELECT 1 FROM tblCTReportAttribute WHERE intReportMasterID = 1 AND intReportAttributeID = 13)
BEGIN
	INSERT INTO tblCTReportAttribute(intReportMasterID,intReportAttributeID,strAttributeName)
	VALUES(1,13,'Open Purchases')
END
GO

GO
IF NOT EXISTS(SELECT 1 FROM tblCTReportAttribute WHERE intReportMasterID = 1 AND intReportAttributeID = 14)
BEGIN
	INSERT INTO tblCTReportAttribute(intReportMasterID,intReportAttributeID,strAttributeName)
	VALUES(1,14,'In-transit Purchases')
END
GO

GO
UPDATE tblCTReportAttribute SET intDisplayOrder = 1 WHERE intReportAttributeID = 1
UPDATE tblCTReportAttribute SET intDisplayOrder = 2 WHERE intReportAttributeID = 2
UPDATE tblCTReportAttribute SET intDisplayOrder = 3 WHERE intReportAttributeID = 3
UPDATE tblCTReportAttribute SET intDisplayOrder = 4 WHERE intReportAttributeID = 4

UPDATE tblCTReportAttribute SET intDisplayOrder = 5 WHERE intReportAttributeID = 13
UPDATE tblCTReportAttribute SET intDisplayOrder = 6 WHERE intReportAttributeID = 14

UPDATE tblCTReportAttribute SET intDisplayOrder = 7 WHERE intReportAttributeID = 5
UPDATE tblCTReportAttribute SET intDisplayOrder = 8 WHERE intReportAttributeID = 6
UPDATE tblCTReportAttribute SET intDisplayOrder = 9 WHERE intReportAttributeID = 7
UPDATE tblCTReportAttribute SET intDisplayOrder = 10 WHERE intReportAttributeID = 8
UPDATE tblCTReportAttribute SET intDisplayOrder = 11 WHERE intReportAttributeID = 9
UPDATE tblCTReportAttribute SET intDisplayOrder = 12 WHERE intReportAttributeID = 10
UPDATE tblCTReportAttribute SET intDisplayOrder = 13 WHERE intReportAttributeID = 11
UPDATE tblCTReportAttribute SET intDisplayOrder = 14 WHERE intReportAttributeID = 12
GO
