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


IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblRKFutOptTransaction]') AND type in (N'U')) 
BEGIN
If EXISTS( SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME='tblRKFutOptTransaction' and COLUMN_NAME='intNoOfContract')
		BEGIN
			ALTER TABLE tblRKFutOptTransaction	ALTER COLUMN intNoOfContract numeric(18,6) 
		END
END

GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblRKFutOptTransactionHistory]') AND type in (N'U')) 
BEGIN
	If EXISTS( SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME='tblRKFutOptTransactionHistory' and COLUMN_NAME='intOldNoOfContract')
	BEGIN
		ALTER TABLE tblRKFutOptTransactionHistory
		ALTER COLUMN intOldNoOfContract numeric(18,6) 
		ALTER TABLE tblRKFutOptTransactionHistory
		ALTER COLUMN intNewNoOfContract numeric(18,6) 
		ALTER TABLE tblRKFutOptTransactionHistory
		ALTER COLUMN intBalanceContract numeric(18,6)
	END

END

GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblRKReconciliationBrokerStatementImport]') AND type in (N'U')) 
BEGIN
	If EXISTS( SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME='tblRKReconciliationBrokerStatementImport' and COLUMN_NAME='intNoOfContract')
	BEGIN
		ALTER TABLE tblRKReconciliationBrokerStatementImport
		ALTER COLUMN intNoOfContract numeric(18,6) 
	END
END
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblRKReconciliationBrokerStatement]') AND type in (N'U')) 
BEGIN
	If EXISTS( SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME='tblRKReconciliationBrokerStatement' and COLUMN_NAME='intNoOfContract')
	BEGIN
		ALTER TABLE tblRKReconciliationBrokerStatement
		ALTER COLUMN intNoOfContract numeric(18,6) 
	END
END
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblRKMatchDerivativesHistoryForOption]') AND type in (N'U')) 
BEGIN
	If EXISTS( SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME='tblRKMatchDerivativesHistoryForOption' and COLUMN_NAME='intMatchQty')
	BEGIN
		ALTER TABLE tblRKMatchDerivativesHistoryForOption
		ALTER COLUMN intMatchQty numeric(18,6) 
	END
END
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblRKAssignFuturesToContractSummary]') AND type in (N'U')) 
BEGIN
	If EXISTS( SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME='tblRKAssignFuturesToContractSummary' and COLUMN_NAME='intHedgedLots')
	BEGIN
		ALTER TABLE tblRKAssignFuturesToContractSummary
		ALTER COLUMN intHedgedLots numeric(18,6) 
	END
END

GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblRKInterCompanyDerivativeEntryStage]') AND type in (N'U')) 
BEGIN
	If EXISTS( SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME='tblRKInterCompanyDerivativeEntryStage' and COLUMN_NAME='intHedgedLots')
	BEGIN
		ALTER TABLE tblRKInterCompanyDerivativeEntryStage
		ALTER COLUMN intHedgedLots numeric(18,6) 
	END
END
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblRKMatchDerivativesHistoryForOption]') AND type in (N'U')) 
BEGIN
	If EXISTS( SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME='tblRKMatchDerivativesHistoryForOption' and COLUMN_NAME='intMatchQty')
	BEGIN
		ALTER TABLE tblRKMatchDerivativesHistoryForOption
		ALTER COLUMN intMatchQty numeric(18,6) 
	END
END

GO


IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblRKOptionsMatchPnS]') AND type in (N'U')) 
BEGIN
	If EXISTS( SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME='tblRKOptionsMatchPnS' and COLUMN_NAME='intMatchQty')
	BEGIN
		ALTER TABLE tblRKOptionsMatchPnS
		ALTER COLUMN intMatchQty numeric(18,6) 
	END
END

GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblRKFutOptTransaction]') AND type in (N'U')) 
BEGIN
	IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'dblNoOfContract' AND OBJECT_ID = OBJECT_ID(N'tblRKFutOptTransaction')) 
	AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intNoOfContract' AND OBJECT_ID = OBJECT_ID(N'tblRKFutOptTransaction'))
    BEGIN
         EXEC sp_rename 'tblRKFutOptTransaction.intNoOfContract', 'dblNoOfContract', 'COLUMN'
    END
END
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblRKFutOptTransactionHistory]') AND type in (N'U')) 
BEGIN
	IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'dblOldNoOfContract' AND OBJECT_ID = OBJECT_ID(N'tblRKFutOptTransactionHistory')) 
	AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intOldNoOfContract' AND OBJECT_ID = OBJECT_ID(N'tblRKFutOptTransactionHistory'))
    BEGIN
          EXEC sp_rename 'tblRKFutOptTransactionHistory.intOldNoOfContract', 'dblOldNoOfContract', 'COLUMN';
    END

	IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'dblNewNoOfContract' AND OBJECT_ID = OBJECT_ID(N'tblRKFutOptTransactionHistory')) 
	AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intNewNoOfContract' AND OBJECT_ID = OBJECT_ID(N'tblRKFutOptTransactionHistory'))
    BEGIN
          EXEC sp_rename 'tblRKFutOptTransactionHistory.intNewNoOfContract', 'dblNewNoOfContract', 'COLUMN';
    END

	IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'dblBalanceContract' AND OBJECT_ID = OBJECT_ID(N'tblRKFutOptTransactionHistory')) 
	AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intBalanceContract' AND OBJECT_ID = OBJECT_ID(N'tblRKFutOptTransactionHistory'))
    BEGIN
          EXEC sp_rename 'tblRKFutOptTransactionHistory.intBalanceContract', 'dblBalanceContract', 'COLUMN';
    END
END
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblRKReconciliationBrokerStatementImport]') AND type in (N'U')) 
BEGIN
	IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'dblNoOfContract' AND OBJECT_ID = OBJECT_ID(N'tblRKReconciliationBrokerStatementImport')) 
	AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intNoOfContract' AND OBJECT_ID = OBJECT_ID(N'tblRKReconciliationBrokerStatementImport'))
    BEGIN
          EXEC sp_rename 'tblRKReconciliationBrokerStatementImport.intNoOfContract', 'dblNoOfContract', 'COLUMN';
    END

END
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblRKReconciliationBrokerStatement]') AND type in (N'U')) 
BEGIN
	IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'dblNoOfContract' AND OBJECT_ID = OBJECT_ID(N'tblRKReconciliationBrokerStatement')) 
	AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intNoOfContract' AND OBJECT_ID = OBJECT_ID(N'tblRKReconciliationBrokerStatement'))
    BEGIN
          EXEC sp_rename 'tblRKReconciliationBrokerStatement.intNoOfContract', 'dblNoOfContract', 'COLUMN';
    END

END

GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblRKMatchDerivativesHistoryForOption]') AND type in (N'U')) 
BEGIN
	IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'dblMatchQty' AND OBJECT_ID = OBJECT_ID(N'tblRKMatchDerivativesHistoryForOption')) 
	AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intMatchQty' AND OBJECT_ID = OBJECT_ID(N'tblRKMatchDerivativesHistoryForOption'))
    BEGIN
          EXEC sp_rename 'tblRKMatchDerivativesHistoryForOption.intMatchQty', 'dblMatchQty', 'COLUMN';
    END

END

GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblRKAssignFuturesToContractSummary]') AND type in (N'U')) 
BEGIN
	IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'dblHedgedLots' AND OBJECT_ID = OBJECT_ID(N'tblRKAssignFuturesToContractSummary')) 
	AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intHedgedLots' AND OBJECT_ID = OBJECT_ID(N'tblRKAssignFuturesToContractSummary'))
    BEGIN
          EXEC sp_rename 'tblRKAssignFuturesToContractSummary.intHedgedLots', 'dblHedgedLots', 'COLUMN';
    END

END

GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblRKInterCompanyDerivativeEntryStage]') AND type in (N'U')) 
BEGIN
	IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'dblHedgedLots' AND OBJECT_ID = OBJECT_ID(N'tblRKInterCompanyDerivativeEntryStage')) 
	AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intHedgedLots' AND OBJECT_ID = OBJECT_ID(N'tblRKInterCompanyDerivativeEntryStage'))
    BEGIN
          EXEC sp_rename 'tblRKInterCompanyDerivativeEntryStage.intHedgedLots', 'dblHedgedLots', 'COLUMN';
    END

END

GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblRKMatchDerivativesHistoryForOption]') AND type in (N'U')) 
BEGIN
	IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'dblMatchQty' AND OBJECT_ID = OBJECT_ID(N'tblRKMatchDerivativesHistoryForOption')) 
	AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intMatchQty' AND OBJECT_ID = OBJECT_ID(N'tblRKMatchDerivativesHistoryForOption'))
    BEGIN
          EXEC sp_rename 'tblRKMatchDerivativesHistoryForOption.intMatchQty', 'dblMatchQty', 'COLUMN';
    END

END

GO


IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblRKOptionsMatchPnS]') AND type in (N'U')) 
BEGIN
	IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'dblMatchQty' AND OBJECT_ID = OBJECT_ID(N'tblRKOptionsMatchPnS')) 
	AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intMatchQty' AND OBJECT_ID = OBJECT_ID(N'tblRKOptionsMatchPnS'))
    BEGIN
          EXEC sp_rename 'tblRKOptionsMatchPnS.intMatchQty', 'dblMatchQty', 'COLUMN';
    END

END
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblRKOptionsPnSExpired]') AND type in (N'U')) 
BEGIN
	If EXISTS( SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME='tblRKOptionsPnSExpired' and COLUMN_NAME='intLots')
	BEGIN
		ALTER TABLE tblRKOptionsPnSExpired
		ALTER COLUMN intLots numeric(18,6) 
	END
END

GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblRKOptionsPnSExpired]') AND type in (N'U')) 
BEGIN
	IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'dblLots' AND OBJECT_ID = OBJECT_ID(N'tblRKOptionsPnSExpired')) 
	AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intLots' AND OBJECT_ID = OBJECT_ID(N'tblRKOptionsPnSExpired'))
    BEGIN
         EXEC sp_rename 'tblRKOptionsPnSExpired.intLots', 'dblLots', 'COLUMN'
    END
END
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblRKOptionsPnSExercisedAssigned]') AND type in (N'U')) 
BEGIN
	If EXISTS( SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME='tblRKOptionsPnSExercisedAssigned' and COLUMN_NAME='intLots')
	BEGIN
		ALTER TABLE tblRKOptionsPnSExercisedAssigned
		ALTER COLUMN intLots numeric(18,6) 
	END
END

GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblRKOptionsPnSExercisedAssigned]') AND type in (N'U')) 
BEGIN
	IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'dblLots' AND OBJECT_ID = OBJECT_ID(N'tblRKOptionsPnSExercisedAssigned')) 
	AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intLots' AND OBJECT_ID = OBJECT_ID(N'tblRKOptionsPnSExercisedAssigned'))
    BEGIN
         EXEC sp_rename 'tblRKOptionsPnSExercisedAssigned.intLots', 'dblLots', 'COLUMN'
    END
END
GO
GO