PRINT N'BEGIN Drop some function for TM'
GO

IF EXISTS (SELECT TOP 1 1 FROM   sys.objects WHERE  object_id = OBJECT_ID(N'[dbo].[fnTMComputeNewBurnRate]') AND type IN (N'FN'))
	EXEC('DROP FUNCTION [dbo].[fnTMComputeNewBurnRate]')
GO 

PRINT N'END Drop some function for TM'
GO