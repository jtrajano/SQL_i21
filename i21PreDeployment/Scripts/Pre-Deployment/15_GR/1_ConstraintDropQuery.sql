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
