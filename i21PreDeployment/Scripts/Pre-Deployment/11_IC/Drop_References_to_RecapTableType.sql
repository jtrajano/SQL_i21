PRINT N'Dropping [dbo].[uspGLValidateGLEntries]...';
GO
	IF EXISTS (SELECT 1 FROM sys.objects WHERE name = 'uspGLValidateGLEntries' and type = 'P') 
		DROP PROCEDURE [dbo].[uspGLValidateGLEntries];
GO

PRINT N'Dropping [dbo].[uspGLBookEntries]...';
GO
	IF EXISTS (SELECT 1 FROM sys.objects WHERE name = 'uspGLBookEntries' and type = 'P') 
		DROP PROCEDURE [dbo].[uspGLBookEntries];
GO

PRINT N'Dropping [dbo].[uspICPostInventoryReceipt]...';
GO
	IF EXISTS (SELECT 1 FROM sys.objects WHERE name = 'uspICPostInventoryReceipt' and type = 'P') 
		DROP PROCEDURE [dbo].[uspICPostInventoryReceipt];
GO

PRINT N'Dropping [dbo].[fnGetGLEntriesErrors]...';
GO
	IF EXISTS (SELECT 1 FROM sys.objects WHERE name = 'fnGetGLEntriesErrors' and type = 'IF') 
		DROP FUNCTION [dbo].[fnGetGLEntriesErrors];
GO
