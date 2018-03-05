GO
PRINT N'Removing obsolete stored procedures in IC'
GO

IF EXISTS(select top 1 1 from sys.procedures where name = 'uspICRebuildZeroCostReceipts')
	EXEC('DROP PROCEDURE uspICRebuildZeroCostReceipts')
GO