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

IF EXISTS(select TABLE_NAME from INFORMATION_SCHEMA.TABLES where TABLE_NAME = 'tblSCTicket')
	BEGIN
		PRINT 'BEGIN CREATE COLUMN strTicketNumber'
		IF NOT EXISTS(SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS WHERE table_name = 'tblSCTicket' AND COLUMN_NAME = 'strTicketNumber')
		BEGIN
			EXEC('
				ALTER TABLE tblSCTicket ADD strTicketNumber NVARCHAR(40) NULL
			');
			EXEC('
				UPDATE tblSCTicket SET strTicketNumber = intTicketNumber
				ALTER TABLE tblSCTicket ALTER COLUMN strTicketNumber NVARCHAR(40) COLLATE Latin1_General_CI_AS NOT NULL
			');
		END
		PRINT 'BEGIN Drop UK_tblSCTicket_intTicketPoolId_intTicketNumber'
		IF EXISTS(SELECT CONSTRAINT_NAME FROM INFORMATION_SCHEMA.CONSTRAINT_TABLE_USAGE WHERE CONSTRAINT_NAME = 'UK_tblSCTicket_intTicketPoolId_intTicketNumber')
		BEGIN
			EXEC('
				ALTER TABLE tblSCTicket DROP CONSTRAINT UK_tblSCTicket_intTicketPoolId_intTicketNumber
				ALTER TABLE tblSCTicket DROP COLUMN intTicketNumber
			');
		END	
	END
GO

IF EXISTS(SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE [TABLE_NAME] = 'tblSCTicketType' AND [COLUMN_NAME] = 'intListTicketTypeId') 
	BEGIN
		PRINT 'DROPPING CONSTRAINT TO tblSCTicketType'
		declare @constraint varchar(500)
		set @constraint = ''
		select @constraint = name from sys.foreign_keys WHERE  OBJECT_NAME(parent_object_id) = 'tblSCTicketType' and OBJECT_NAME(referenced_object_id) = 'tblSCListTicketTypes' 

		if(@constraint <> '')
		exec('ALTER TABLE tblSCTicketType DROP CONSTRAINT [' + @constraint +']' )
	END
GO 


IF EXISTS(SELECT * FROM INFORMATION_SCHEMA.CONSTRAINT_TABLE_USAGE WHERE CONSTRAINT_NAME = 'FK_tblSCScaleSetup_tblICUnitMeasure_intUnitMeasureId')
	BEGIN
		PRINT 'BEGIN Drop FK_tblSCScaleSetup_tblICUnitMeasure_intUnitMeasureId'
		EXEC('
			ALTER TABLE tblSCScaleSetup
			DROP CONSTRAINT FK_tblSCScaleSetup_tblICUnitMeasure_intUnitMeasureId		
		');
		PRINT 'END Drop FK_tblSCScaleSetup_tblICUnitMeasure_intUnitMeasureId'
	END	
GO
