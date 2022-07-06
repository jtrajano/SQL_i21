GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE name = 'uspCTUpdateItemContractSequenceBalance')
BEGIN
	EXEC ('DROP PROCEDURE uspCTUpdateItemContractSequenceBalance') 
END
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE name = 'uspCTUpdateItemContractSequenceQuantity')
BEGIN
	EXEC ('DROP PROCEDURE uspCTUpdateItemContractSequenceQuantity') 
END
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE name = 'vyuCTRawToWipConversion')
BEGIN
	EXEC ('DROP VIEW vyuCTRawToWipConversion') 
END
GO

IF EXISTS(SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'tblCTContractHeader' AND COLUMN_NAME = 'intLastEntityId')
BEGIN
	EXEC('ALTER TABLE tblCTContractHeader DROP COLUMN intLastEntityId')
END
GO