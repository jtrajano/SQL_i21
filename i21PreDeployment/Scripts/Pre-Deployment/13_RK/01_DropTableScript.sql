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
	IF EXISTS(SELECT TOP 1 1 FROM tblRKFutOptTransactionImport)
	BEGIN
		EXEC('DELETE FROM tblRKFutOptTransactionImport')
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

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblRKCompanyPreference]') AND type IN (N'U'))
BEGIN
	IF EXISTS (SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'tblRKCompanyPreference' AND COLUMN_NAME = 'ysnM2MAllowExpiredMonth')
	BEGIN
		IF NOT EXISTS (SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'tblRKCompanyPreference' AND COLUMN_NAME = 'intMarkExpiredMonthPositionId')
		BEGIN
			EXEC('ALTER TABLE tblRKCompanyPreference ADD intMarkExpiredMonthPositionId INT')
		END

		EXEC('UPDATE tblRKCompanyPreference SET intMarkExpiredMonthPositionId = CASE WHEN ISNULL(ysnM2MAllowExpiredMonth, 0) = 0 THEN 1 ELSE 2 END')
	END
END

GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblRKM2MConfiguration]') AND type IN (N'U'))
BEGIN
	IF NOT EXISTS (SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'tblRKM2MConfiguration' AND COLUMN_NAME = 'strContractType')
	BEGIN
		EXEC('ALTER TABLE tblRKM2MConfiguration ADD strContractType NVARCHAR(20)')
		EXEC('UPDATE tblRKM2MConfiguration SET strContractType = ''Both''')
	END
END

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblRKM2MConfiguration]') AND type IN (N'U'))
BEGIN
	IF EXISTS (SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'tblRKM2MConfiguration' AND COLUMN_NAME = 'strContractType')
	BEGIN
		IF EXISTS (SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'tblRKM2MConfiguration' AND COLUMN_NAME = 'intFreightTermId')
		BEGIN
			EXEC('DELETE FROM tblRKM2MConfiguration
				WHERE intM2MConfigurationId IN (
					SELECT intM2MConfigurationId FROM (
						SELECT Config.intItemId
							, Config.strContractType
							, Config.intFreightTermId
							, Config.strAdjustmentType
							, intM2MConfigurationId = MAX(intM2MConfigurationId)
						FROM tblRKM2MConfiguration Config
						JOIN (
							SELECT intItemId
								, strContractType
								, intFreightTermId
								, strAdjustmentType
							FROM tblRKM2MConfiguration
							GROUP BY intItemId
								, strContractType
								, intFreightTermId
								, strAdjustmentType
							HAVING COUNT(*) > 1
						) tbl ON tbl.intItemId = Config.intItemId
							AND tbl.strContractType = Config.strContractType
							AND tbl.intFreightTermId = Config.intFreightTermId
							AND tbl.strAdjustmentType = Config.strAdjustmentType
						GROUP BY Config.intItemId
							, Config.strContractType
							, Config.intFreightTermId
							, Config.strAdjustmentType
					) tbl
				)')
		END
		ELSE
		BEGIN
			EXEC('DELETE FROM tblRKM2MConfiguration
				WHERE intM2MConfigurationId IN (
					SELECT intM2MConfigurationId FROM (
						SELECT Config.intItemId
							, Config.strContractType
							, Config.strAdjustmentType
							, intM2MConfigurationId = MAX(intM2MConfigurationId)
						FROM tblRKM2MConfiguration Config
						JOIN (
							SELECT intItemId
								, strContractType
								, strAdjustmentType
							FROM tblRKM2MConfiguration
							GROUP BY intItemId
								, strContractType
								, strAdjustmentType
							HAVING COUNT(*) > 1
						) tbl ON tbl.intItemId = Config.intItemId
							AND tbl.strContractType = Config.strContractType
							AND tbl.strAdjustmentType = Config.strAdjustmentType
						GROUP BY Config.intItemId
							, Config.strContractType
							, Config.strAdjustmentType
					) tbl
				)')
		END
	END
	ELSE IF EXISTS (SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'tblRKM2MConfiguration' AND COLUMN_NAME = 'strAdjustmentType')
	BEGIN
		EXEC('DELETE FROM tblRKM2MConfiguration
			WHERE intM2MConfigurationId IN (
				SELECT intM2MConfigurationId FROM (
					SELECT Config.intItemId
						, Config.strAdjustmentType
						, intM2MConfigurationId = MAX(intM2MConfigurationId)
					FROM tblRKM2MConfiguration Config
					JOIN (
						SELECT intItemId
							, strAdjustmentType
						FROM tblRKM2MConfiguration
						GROUP BY intItemId
							, strAdjustmentType
						HAVING COUNT(*) > 1
					) tbl ON tbl.intItemId = Config.intItemId
						AND tbl.strAdjustmentType = Config.strAdjustmentType
					GROUP BY Config.intItemId
						, Config.strAdjustmentType
				) tbl
			)')
	END
END

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblRKCompanyPreference]') AND type IN (N'U'))
BEGIN
	IF NOT EXISTS (SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'tblRKCompanyPreference' AND COLUMN_NAME = 'intRiskViewId')
	BEGIN
		EXEC('ALTER TABLE tblRKCompanyPreference ADD intRiskViewId INT')
	END

	IF EXISTS (SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'tblRKCompanyPreference' AND COLUMN_NAME = 'strRiskView')
	BEGIN
		EXEC('UPDATE tblRKCompanyPreference SET intRiskViewId = CASE WHEN strRiskView = ''Trader/Elevator'' THEN 1
																	WHEN strRiskView = ''Processor'' THEN 2
																	WHEN strRiskView = ''Trader 2'' THEN 3 END')
	END

	
END

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblRKTempDPRDetailLog]') AND type IN (N'U'))
BEGIN
	IF NOT EXISTS (SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'tblRKTempDPRDetailLog' AND COLUMN_NAME = 'intTransactionReferenceDetailId')
	BEGIN
		EXEC('ALTER TABLE tblRKTempDPRDetailLog ADD intTransactionReferenceDetailId INT')
	END
END

GO