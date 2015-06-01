/*
 Pre-Deployment Script Template							
--------------------------------------------------------------------------------------
 This file contains SQL statements that will be executed before the build script.	
 Use SQLCMD syntax to include a file in the pre-deployment script.			
 Example:      :r .\myfile.sql								
 Use SQLCMD syntax to reference a variable in the pre-deployment script.		
 Example:      :setvar TableName MyTable							
               SELECT * FROM [$(TableName)]					
--------------------------------------------------------------------------------------
*/
GO
PRINT 'BEGIN Drop PK_tblGRStorageType'

IF EXISTS(SELECT TOP 1 1 FROM sys.objects WHERE name = 'PK_tblGRStorageType' AND type = 'PK' AND parent_object_id = OBJECT_ID('tblGRStorageType', 'U'))
BEGIN
	EXEC('
		ALTER TABLE tblGRStorageType
		DROP CONSTRAINT PK_tblGRStorageType		
	');
END

GO
PRINT 'END Drop PK_tblGRStorageType'

GO

PRINT 'BEGIN Drop AK_tblGRStorageType_strStorageType'

IF EXISTS(SELECT TOP 1 1 FROM sys.objects WHERE name = 'AK_tblGRStorageType_strStorageType' AND type = 'UQ' AND parent_object_id = OBJECT_ID('tblGRStorageType', 'U'))
BEGIN
	EXEC('
		ALTER TABLE tblGRStorageType
		DROP CONSTRAINT AK_tblGRStorageType_strStorageType		
	');
END

GO
PRINT 'END Drop AK_tblGRStorageType_strStorageType'

GO
PRINT 'BEGIN Drop PK_tblRKMarketExchange'

IF EXISTS(SELECT TOP 1 1 FROM sys.objects WHERE name = 'PK_tblRKMarketExchange' AND type = 'PK' AND parent_object_id = OBJECT_ID('tblRKMarketExchange', 'U'))
BEGIN
	IF EXISTS(SELECT * FROM INFORMATION_SCHEMA.CONSTRAINT_TABLE_USAGE WHERE CONSTRAINT_NAME = 'FK_tblRKElectronicPricing_tblRKMarketExchange')
	BEGIN
		EXEC('
			ALTER TABLE tblRKElectronicPricing
			DROP CONSTRAINT FK_tblRKElectronicPricing_tblRKMarketExchange		
		');
	END	
	EXEC('
		ALTER TABLE tblRKMarketExchange
		DROP CONSTRAINT PK_tblRKMarketExchange		
	');
END
GO
PRINT 'END Drop PK_tblRKMarketExchange'
GO

PRINT 'BEGIN Drop FK_tblRKElectronicPricing_tblRKFutureMarket'
IF EXISTS(SELECT * FROM INFORMATION_SCHEMA.CONSTRAINT_TABLE_USAGE WHERE CONSTRAINT_NAME = 'FK_tblRKElectronicPricing_tblRKFutureMarket')
	BEGIN
		EXEC('
			ALTER TABLE tblRKElectronicPricing
			DROP CONSTRAINT FK_tblRKElectronicPricing_tblRKFutureMarket		
		');
	END	
GO
PRINT 'END Drop FK_tblRKElectronicPricing_tblRKFutureMarket'
GO