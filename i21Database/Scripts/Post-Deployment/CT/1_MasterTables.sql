--tblCTBuySell
GO
IF NOT EXISTS(SELECT * FROM tblCTBuySell WHERE Name = 'Buy')
BEGIN
	INSERT INTO tblCTBuySell
	SELECT 1,'Buy',1
END
GO

GO
IF NOT EXISTS(SELECT * FROM tblCTBuySell WHERE Name = 'Sell')
BEGIN
	INSERT INTO tblCTBuySell
	SELECT 2,'Sell',1	
END
GO

--tblCTCashOrFuture
GO
IF NOT EXISTS(SELECT * FROM tblCTCashOrFuture WHERE Name = 'Cash')
BEGIN
	INSERT INTO tblCTCashOrFuture
	SELECT 1,'Cash',1	
END
GO

GO
IF NOT EXISTS(SELECT * FROM tblCTCashOrFuture WHERE Name = 'Futures')
BEGIN
	INSERT INTO tblCTCashOrFuture
	SELECT 2,'Futures',1	
END
GO

GO
IF NOT EXISTS(SELECT * FROM tblCTCashOrFuture WHERE Name = 'Either')
BEGIN
	INSERT INTO tblCTCashOrFuture
	SELECT 3,'Either',1	
END
GO

--tblCTCostMethod
GO
IF NOT EXISTS(SELECT * FROM tblCTCostMethod WHERE Name = 'Per Unit')
BEGIN
	INSERT INTO tblCTCostMethod
	SELECT 1,'Per Unit',1	
END
GO

GO
IF NOT EXISTS(SELECT * FROM tblCTCostMethod WHERE Name = '%')
BEGIN
	INSERT INTO tblCTCostMethod
	SELECT 2,'%',1	
END
GO

GO
IF NOT EXISTS(SELECT * FROM tblCTCostMethod WHERE Name = 'Amount')
BEGIN
	INSERT INTO tblCTCostMethod
	SELECT 3,'Amount',1	
END
GO

--tblCTPremFee
GO
IF NOT EXISTS(SELECT * FROM tblCTPremFee WHERE Name = 'Bill to Customer')
BEGIN
	INSERT INTO tblCTPremFee
	SELECT 1,'Bill to Customer',1	
END
GO

GO
IF NOT EXISTS(SELECT * FROM tblCTPremFee WHERE Name = 'Deduct from settlement')
BEGIN
	INSERT INTO tblCTPremFee
	SELECT 2,'Deduct from settlement',1	
END
GO

--tblCTPricingType
GO
IF NOT EXISTS(SELECT * FROM tblCTPricingType WHERE Name = 'Priced')
BEGIN
	INSERT INTO tblCTPricingType
	SELECT 1,'Priced',1	
END
GO

GO
IF NOT EXISTS(SELECT * FROM tblCTPricingType WHERE Name = 'Basis')
BEGIN
	INSERT INTO tblCTPricingType
	SELECT 2,'Basis',1	
END
GO

GO
IF NOT EXISTS(SELECT * FROM tblCTPricingType WHERE Name = 'HTA')
BEGIN
	INSERT INTO tblCTPricingType
	SELECT 3,'HTA',1	
END
GO

GO
IF NOT EXISTS(SELECT * FROM tblCTPricingType WHERE Name = 'TBD')
BEGIN
	INSERT INTO tblCTPricingType
	SELECT 4,'TBD',1	
END
GO

GO
IF NOT EXISTS(SELECT * FROM tblCTPricingType WHERE Name = 'Canadian Basis')
BEGIN
	INSERT INTO tblCTPricingType
	SELECT 5,'Canadian Basis',1	
END
GO

--tblCTPutCall
GO
IF NOT EXISTS(SELECT * FROM tblCTPutCall WHERE Name = 'Put')
BEGIN
	INSERT INTO tblCTPutCall
	SELECT 1,'Put',1	
END
GO

GO
IF NOT EXISTS(SELECT * FROM tblCTPutCall WHERE Name = 'Call')
BEGIN
	INSERT INTO tblCTPutCall
	SELECT 2,'Call',1	
END
GO

--tblCTRailGrade
GO
IF NOT EXISTS(SELECT * FROM tblCTRailGrade WHERE Name = 'Average')
BEGIN
	INSERT INTO tblCTRailGrade
	SELECT 1,'Average',1	
END
GO

GO
IF NOT EXISTS(SELECT * FROM tblCTRailGrade WHERE Name = 'Car')
BEGIN
	INSERT INTO tblCTRailGrade
	SELECT 2,'Car',1	
END
GO
