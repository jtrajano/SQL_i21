
-- Manually drop stored procedures

PRINT N'BEGIN CASH MANAGEMENT DELETE PATH: 14.1 to 14.2'

PRINT N'Dropping [dbo].[PostRecap]...';
GO
	IF EXISTS (SELECT 1 FROM sys.objects WHERE name = 'PostRecap' and type = 'P') DROP PROCEDURE [dbo].[PostRecap];
GO
PRINT N'Dropping [dbo].[BookGLEntries]...';
GO
	IF EXISTS (SELECT 1 FROM sys.objects WHERE name = 'BookGLEntries' and type = 'P') DROP PROCEDURE [dbo].[BookGLEntries];
GO
PRINT N'Dropping [dbo].[PostCMBankTransfer]...';
GO
	IF EXISTS (SELECT 1 FROM sys.objects WHERE name = 'PostCMBankTransfer' and type = 'P') DROP PROCEDURE [dbo].[PostCMBankTransfer];
GO
PRINT N'Dropping [dbo].[PostCMBankDeposit]...';
GO
	IF EXISTS (SELECT 1 FROM sys.objects WHERE name = 'PostCMBankDeposit' and type = 'P') DROP PROCEDURE [dbo].[PostCMBankDeposit];
GO
PRINT N'Dropping [dbo].[PostCMBankTransaction]...';
GO
	IF EXISTS (SELECT 1 FROM sys.objects WHERE name = 'PostCMBankTransaction' and type = 'P') DROP PROCEDURE [dbo].[PostCMBankTransaction];
GO
PRINT N'Dropping [dbo].[PostCMMiscChecks]...';
GO
	IF EXISTS (SELECT 1 FROM sys.objects WHERE name = 'PostCMMiscChecks' and type = 'P') DROP PROCEDURE [dbo].[PostCMMiscChecks];
GO
PRINT N'Dropping [dbo].[RecapTableType]...';
GO
	IF EXISTS (SELECT 1 FROM sys.table_types WHERE name = 'RecapTableType') DROP TYPE [dbo].[RecapTableType]
GO

PRINT N'END CASH MANAGEMENT DELETE PATH: 14.1 to 14.2'