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
IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblRKElectonicPricing]') AND type in (N'U')) 
BEGIN
    DROP TABLE tblRKElectonicPricing
END

GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE name = 'tblRKM2MInquiryTransaction' AND type ='U')
	BEGIN
		EXEC('update  tblRKM2MInquiryTransaction set intItemId = NULL where intItemId not in(select intItemId from tblICItem)')
	END

GO

PRINT('/*******************  BEGIN Fix for tblRKFutOptTransactionImport.dtmCreateDateTime AND dtmFilledDate *******************/')

IF EXISTS(SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE [TABLE_NAME] = 'tblRKFutOptTransactionImport' AND [COLUMN_NAME] = 'dtmCreateDateTime' AND [DATA_TYPE] = 'nvarchar')
	AND EXISTS(SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE [TABLE_NAME] = 'tblRKFutOptTransactionImport' AND [COLUMN_NAME] = 'dtmFilledDate' AND [DATA_TYPE] = 'nvarchar')
BEGIN
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblRKFutOptTransactionImport)
	BEGIN
		EXEC('ALTER TABLE [dbo].[tblRKFutOptTransactionImport] ALTER COLUMN [dtmFilledDate] DATETIME NULL
			ALTER TABLE [dbo].[tblRKFutOptTransactionImport] ALTER COLUMN [dtmCreateDateTime] DATETIME NULL')
	END
	ELSE
	BEGIN
		EXEC('
		DECLARE @tmpFutOptTransactionImport TABLE(
			intFutOptTransactionId INT
			,dtmCreateDateTime DATETIME
			,dtmFilledDate DATETIME
		)

		INSERT INTO @tmpFutOptTransactionImport (
			intFutOptTransactionId
			,dtmCreateDateTime
			,dtmFilledDate
		)
		SELECT intFutOptTransactionId
			,dtmCreateDateTime = CONVERT(DATETIME, LEFT(LTRIM(RTRIM(dtmCreateDateTime)),4) + ''/'' + RIGHT(LEFT(LTRIM(RTRIM(dtmCreateDateTime)),10),2) + ''/'' + SUBSTRING(LEFT(LTRIM(RTRIM(dtmCreateDateTime)),10), 6, 2) + SUBSTRING(LTRIM(RTRIM(dtmCreateDateTime)),11, LEN(dtmCreateDateTime)))
			,dtmFilledDate = CONVERT(DATETIME, LEFT(LTRIM(RTRIM(dtmFilledDate)),4) + ''/'' + RIGHT(LEFT(LTRIM(RTRIM(dtmFilledDate)),10),2) + ''/'' + SUBSTRING(LEFT(LTRIM(RTRIM(dtmFilledDate)),10), 6, 2) + SUBSTRING(LTRIM(RTRIM(dtmCreateDateTime)),11, LEN(dtmCreateDateTime)))
		FROM tblRKFutOptTransactionImport

		UPDATE tblRKFutOptTransactionImport
			SET dtmCreateDateTime = NULL,
				dtmFilledDate = NULL

		ALTER TABLE [dbo].[tblRKFutOptTransactionImport] ALTER COLUMN [dtmFilledDate] DATETIME NULL
		ALTER TABLE [dbo].[tblRKFutOptTransactionImport] ALTER COLUMN [dtmCreateDateTime] DATETIME NULL

		UPDATE FOTI
			SET FOTI.dtmCreateDateTime = T.dtmCreateDateTime,
				FOTI.dtmFilledDate = T.dtmFilledDate
		FROM tblRKFutOptTransactionImport FOTI
		INNER JOIN @tmpFutOptTransactionImport T ON T.intFutOptTransactionId = FOTI.intFutOptTransactionId')
	END
END

PRINT('/*******************  END Fix for tblRKFutOptTransactionImport.dtmCreateDateTime AND dtmFilledDate *******************/')

GO