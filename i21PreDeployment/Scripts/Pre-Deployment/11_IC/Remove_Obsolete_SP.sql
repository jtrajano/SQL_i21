GO
PRINT N'Removing obsolete stored procedures in IC'

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[uspICRebuildZeroCostReceipts]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].uspICRebuildZeroCostReceipts

GO