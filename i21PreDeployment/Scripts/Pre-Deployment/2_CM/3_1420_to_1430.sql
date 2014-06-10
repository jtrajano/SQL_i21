
PRINT N'BEGIN CASH MANAGEMENT DELETE PATH: 14.2 to 14.3'

-- Drop the view (apchkmst) because of the schema change in tblCMBankTransaction.
PRINT N'Dropping View: [dbo].[apchkmst]...';
GO
	IF EXISTS(select top 1 1 from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = 'apchkmst')
		DROP VIEW apchkmst
GO

PRINT N'Drop tblCMUndepositedFund table (if no data exists)';
GO
	IF OBJECT_ID('tblCMUndepositedFund', 'U') IS NOT NULL 
		IF NOT EXISTS(SELECT TOP 1 1 FROM tblCMUndepositedFund) -- Drop table if no data is found. 
			DROP TABLE tblCMUndepositedFund
GO

-- 1 of 2: Drop old stored procedures referencing RecapTableType. 
PRINT N'Dropping [dbo].[uspCMPostRecap]...';
GO
	IF EXISTS (SELECT 1 FROM sys.objects WHERE name = 'uspCMPostRecap' and type = 'P') DROP PROCEDURE [dbo].[uspCMPostRecap];
GO
PRINT N'Dropping [dbo].[uspCMBookGLEntries]...';
GO
	IF EXISTS (SELECT 1 FROM sys.objects WHERE name = 'uspCMBookGLEntries' and type = 'P') DROP PROCEDURE [dbo].[uspCMBookGLEntries];
GO
PRINT N'Dropping [dbo].[uspCMPostBankTransfer]...';
GO
	IF EXISTS (SELECT 1 FROM sys.objects WHERE name = 'uspCMPostBankTransfer' and type = 'P') DROP PROCEDURE [dbo].[uspCMPostBankTransfer];
GO
PRINT N'Dropping [dbo].[uspCMPostBankDeposit]...';
GO
	IF EXISTS (SELECT 1 FROM sys.objects WHERE name = 'uspCMPostBankDeposit' and type = 'P') DROP PROCEDURE [dbo].[uspCMPostBankDeposit];
GO
PRINT N'Dropping [dbo].[uspCMPostBankTransaction]...';
GO
	IF EXISTS (SELECT 1 FROM sys.objects WHERE name = 'uspCMPostBankTransaction' and type = 'P') DROP PROCEDURE [dbo].[uspCMPostBankTransaction];
GO
PRINT N'Dropping [dbo].[uspCMPostMiscChecks]...';
GO
	IF EXISTS (SELECT 1 FROM sys.objects WHERE name = 'uspCMPostMiscChecks' and type = 'P') DROP PROCEDURE [dbo].[uspCMPostMiscChecks];
GO

-- 2 of 2: Drop RecapTableType
PRINT N'Dropping [dbo].[RecapTableType]...';
GO
	IF EXISTS (SELECT 1 FROM sys.table_types WHERE name = 'RecapTableType') DROP TYPE [dbo].[RecapTableType]
GO

PRINT N'END CASH MANAGEMENT DELETE PATH: 14.2 to 14.3'