
---- 1 of 3: Drop old stored procedures referencing RecapTableType. 
--PRINT N'BEGIN CASH MANAGEMENT DELETE PATH: 14.1 to 14.2'

--PRINT N'Dropping [dbo].[PostRecap]...';
--GO
--	IF EXISTS (SELECT 1 FROM sys.objects WHERE name = 'PostRecap' and type = 'P') DROP PROCEDURE [dbo].[PostRecap];
--GO
--PRINT N'Dropping [dbo].[BookGLEntries]...';
--GO
--	IF EXISTS (SELECT 1 FROM sys.objects WHERE name = 'BookGLEntries' and type = 'P') DROP PROCEDURE [dbo].[BookGLEntries];
--GO
--PRINT N'Dropping [dbo].[PostCMBankTransfer]...';
--GO
--	IF EXISTS (SELECT 1 FROM sys.objects WHERE name = 'PostCMBankTransfer' and type = 'P') DROP PROCEDURE [dbo].[PostCMBankTransfer];
--GO
--PRINT N'Dropping [dbo].[PostCMBankDeposit]...';
--GO
--	IF EXISTS (SELECT 1 FROM sys.objects WHERE name = 'PostCMBankDeposit' and type = 'P') DROP PROCEDURE [dbo].[PostCMBankDeposit];
--GO
--PRINT N'Dropping [dbo].[PostCMBankTransaction]...';
--GO
--	IF EXISTS (SELECT 1 FROM sys.objects WHERE name = 'PostCMBankTransaction' and type = 'P') DROP PROCEDURE [dbo].[PostCMBankTransaction];
--GO
--PRINT N'Dropping [dbo].[PostCMMiscChecks]...';
--GO
--	IF EXISTS (SELECT 1 FROM sys.objects WHERE name = 'PostCMMiscChecks' and type = 'P') DROP PROCEDURE [dbo].[PostCMMiscChecks];
--GO

---- 2 of 3: Drop new stored procedures referencing RecapTableType. 
--PRINT N'Dropping [dbo].[uspCMPostRecap]...';
--GO
--	IF EXISTS (SELECT 1 FROM sys.objects WHERE name = 'uspCMPostRecap' and type = 'P') DROP PROCEDURE [dbo].[uspCMPostRecap];
--GO

--PRINT N'Dropping [dbo].[uspCMBookGLEntries]...';
--GO
--	IF EXISTS (SELECT 1 FROM sys.objects WHERE name = 'uspCMBookGLEntries' and type = 'P') DROP PROCEDURE [dbo].[uspCMBookGLEntries];
--GO

--PRINT N'Dropping [dbo].[uspCMPostBankDeposit]...';
--GO
--	IF EXISTS (SELECT 1 FROM sys.objects WHERE name = 'uspCMPostBankDeposit' and type = 'P') DROP PROCEDURE [dbo].[uspCMPostBankDeposit];
--GO

--PRINT N'Dropping [dbo].[uspCMPostBankTransaction]...';
--GO
--	IF EXISTS (SELECT 1 FROM sys.objects WHERE name = 'uspCMPostBankTransaction' and type = 'P') DROP PROCEDURE [dbo].[uspCMPostBankTransaction];
--GO

--PRINT N'Dropping [dbo].[uspCMPostBankTransfer]...';
--GO
--	IF EXISTS (SELECT 1 FROM sys.objects WHERE name = 'uspCMPostBankTransfer' and type = 'P') DROP PROCEDURE [dbo].[uspCMPostBankTransfer];
--GO

--PRINT N'Dropping [dbo].[uspCMPostMiscChecks]...';
--GO
--	IF EXISTS (SELECT 1 FROM sys.objects WHERE name = 'uspCMPostMiscChecks' and type = 'P') DROP PROCEDURE [dbo].[uspCMPostMiscChecks];
--GO

---- 3 of 3: Drop RecapTableType
--PRINT N'Dropping [dbo].[RecapTableType]...';
--GO
--	IF EXISTS (SELECT 1 FROM sys.table_types WHERE name = 'RecapTableType') DROP TYPE [dbo].[RecapTableType]
--GO

--PRINT N'END CASH MANAGEMENT DELETE PATH: 14.1 to 14.2'