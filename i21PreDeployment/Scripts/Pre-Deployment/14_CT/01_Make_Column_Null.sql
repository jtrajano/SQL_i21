GO
IF EXISTS(SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME LIKE 'tblCTContractDetail' AND COLUMN_NAME LIKE 'strFuturesMonth')
BEGIN
	EXEC('UPDATE  tblCTContractDetail SET strFuturesMonth = NULL')
END
GO

GO
PRINT 'BEGIN Drop PK_tblCTBuySell_Value'

IF EXISTS(SELECT TOP 1 1 FROM sys.objects WHERE name = 'PK_tblCTBuySell_Value' AND type = 'PK' AND parent_object_id = OBJECT_ID('tblCTBuySell', 'U'))
BEGIN
	IF EXISTS(SELECT * FROM INFORMATION_SCHEMA.CONSTRAINT_TABLE_USAGE WHERE CONSTRAINT_NAME = 'FK_tblCTContractOption_tblCTBuySell_intBuySell')
	BEGIN
		EXEC('
			ALTER TABLE tblCTContractOption
			DROP CONSTRAINT FK_tblCTContractOption_tblCTBuySell_intBuySell		
		');
	END

	EXEC('
		ALTER TABLE tblCTBuySell
		DROP CONSTRAINT PK_tblCTBuySell_Value		
	');
END

GO
PRINT 'END Drop PK_tblCTBuySell_Value'

GO

GO
PRINT 'BEGIN Drop PK_tblCTCostMethod_Value'

IF EXISTS(SELECT TOP 1 1 FROM sys.objects WHERE name = 'PK_tblCTCostMethod_Value' AND type = 'PK' AND parent_object_id = OBJECT_ID('tblCTCostMethod', 'U'))
BEGIN
	IF EXISTS(SELECT * FROM INFORMATION_SCHEMA.CONSTRAINT_TABLE_USAGE WHERE CONSTRAINT_NAME = 'FK_tblCTContractCost_tblCTCostMethod_intCostMethod')
	BEGIN
		EXEC('
			ALTER TABLE tblCTContractCost
			DROP CONSTRAINT FK_tblCTContractCost_tblCTCostMethod_intCostMethod		
		');
	END	
	IF EXISTS(SELECT * FROM INFORMATION_SCHEMA.CONSTRAINT_TABLE_USAGE WHERE CONSTRAINT_NAME = 'FK_tblCTCostType_tblCTCostMethod_intCostMethod')
	BEGIN
		EXEC('
			ALTER TABLE tblCTCostType
			DROP CONSTRAINT FK_tblCTCostType_tblCTCostMethod_intCostMethod		
		');
	END
	EXEC('
		ALTER TABLE tblCTCostMethod
		DROP CONSTRAINT PK_tblCTCostMethod_Value		
	');
END

GO
PRINT 'END Drop PK_tblCTCostMethod_Value'

GO

GO
PRINT 'BEGIN Drop PK_tblCTPremFee_Value'

IF EXISTS(SELECT TOP 1 1 FROM sys.objects WHERE name = 'PK_tblCTPremFee_Value' AND type = 'PK' AND parent_object_id = OBJECT_ID('tblCTPremFee', 'U'))
BEGIN
	IF EXISTS(SELECT * FROM INFORMATION_SCHEMA.CONSTRAINT_TABLE_USAGE WHERE CONSTRAINT_NAME = 'FK_tblCTContractOption_tblCTPremFee_intPremFee')
	BEGIN
		EXEC('
			ALTER TABLE tblCTContractOption
			DROP CONSTRAINT FK_tblCTContractOption_tblCTPremFee_intPremFee		
		');
	END	
	EXEC('
		ALTER TABLE tblCTPremFee
		DROP CONSTRAINT PK_tblCTPremFee_Value		
	');
END

GO
PRINT 'END Drop PK_tblCTPremFee_Value'

GO

GO
PRINT 'BEGIN Drop PK_tblCTPricingType_Value'

IF EXISTS(SELECT TOP 1 1 FROM sys.objects WHERE name = 'PK_tblCTPricingType_Value' AND type = 'PK' AND parent_object_id = OBJECT_ID('tblCTPricingType', 'U'))
BEGIN
	IF EXISTS(SELECT * FROM INFORMATION_SCHEMA.CONSTRAINT_TABLE_USAGE WHERE CONSTRAINT_NAME = 'FK_tblCTContractDetail_tblCTPricingType_intPricingType')
	BEGIN
		EXEC('
			ALTER TABLE tblCTContractDetail
			DROP CONSTRAINT FK_tblCTContractDetail_tblCTPricingType_intPricingType		
		');
	END	
	IF EXISTS(SELECT * FROM INFORMATION_SCHEMA.CONSTRAINT_TABLE_USAGE WHERE CONSTRAINT_NAME = 'FK_tblCTContractHeader_tblCTPricingType_intPricingType')
	BEGIN
		EXEC('
			ALTER TABLE tblCTContractHeader
			DROP CONSTRAINT FK_tblCTContractHeader_tblCTPricingType_intPricingType		
		');
	END
	EXEC('
		ALTER TABLE tblCTPricingType
		DROP CONSTRAINT PK_tblCTPricingType_Value		
	');
END

GO
PRINT 'END Drop PK_tblCTPricingType_Value'

GO

GO
PRINT 'BEGIN Drop PK_tblCTPutCall_Value'

IF EXISTS(SELECT TOP 1 1 FROM sys.objects WHERE name = 'PK_tblCTPutCall_Value' AND type = 'PK' AND parent_object_id = OBJECT_ID('tblCTPutCall', 'U'))
BEGIN
	IF EXISTS(SELECT * FROM INFORMATION_SCHEMA.CONSTRAINT_TABLE_USAGE WHERE CONSTRAINT_NAME = 'FK_tblCTContractOption_tblCTPutCall_intPutCall')
	BEGIN
		EXEC('
			ALTER TABLE tblCTContractOption
			DROP CONSTRAINT FK_tblCTContractOption_tblCTPutCall_intPutCall		
		');
	END	
	EXEC('
		ALTER TABLE tblCTPutCall
		DROP CONSTRAINT PK_tblCTPutCall_Value		
	');
END

GO
PRINT 'END Drop PK_tblCTPutCall_Value'

GO

GO
PRINT 'BEGIN Drop PK_tblCTRailGrade_Value'

IF EXISTS(SELECT TOP 1 1 FROM sys.objects WHERE name = 'PK_tblCTRailGrade_Value' AND type = 'PK' AND parent_object_id = OBJECT_ID('tblCTRailGrade', 'U'))
BEGIN
	IF EXISTS(SELECT * FROM INFORMATION_SCHEMA.CONSTRAINT_TABLE_USAGE WHERE CONSTRAINT_NAME = 'FK_tblCTContractDetail_tblCTRailGrade_intGrade')
	BEGIN
		EXEC('
			ALTER TABLE tblCTContractDetail
			DROP CONSTRAINT FK_tblCTContractDetail_tblCTRailGrade_intGrade		
		');
	END	
	EXEC('
		ALTER TABLE tblCTRailGrade
		DROP CONSTRAINT PK_tblCTRailGrade_Value		
	');
END

GO
PRINT 'END Drop PK_tblCTRailGrade_Value'

GO

GO
PRINT 'BEGIN Drop PK_tblCTContractType_Value'

IF EXISTS(SELECT TOP 1 1 FROM sys.objects WHERE name = 'PK_tblCTContractType_Value' AND type = 'PK' AND parent_object_id = OBJECT_ID('tblCTContractType', 'U'))
BEGIN
	EXEC('
		ALTER TABLE tblCTContractType
		DROP CONSTRAINT PK_tblCTContractType_Value		
	');
END

GO
PRINT 'END Drop PK_tblCTContractType_Value'

GO

GO
PRINT 'BEGIN Drop UQ_tblCTContractHeader_intPurchaseSale_intContractNumber'

IF EXISTS(SELECT TOP 1 1 FROM sys.objects WHERE name = 'UQ_tblCTContractHeader_intPurchaseSale_intContractNumber' AND type = 'UQ' AND parent_object_id = OBJECT_ID('tblCTContractHeader', 'U'))
BEGIN
	EXEC('
		ALTER TABLE tblCTContractHeader
		DROP CONSTRAINT UQ_tblCTContractHeader_intPurchaseSale_intContractNumber		
	');
END

GO
PRINT 'END Drop UQ_tblCTContractHeader_intPurchaseSale_intContractNumber'

GO