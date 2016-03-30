PRINT N'BEGIN Drop some view for TM'
GO

IF EXISTS(select top 1 1 from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = 'vwprcmst')
	DROP VIEW vwprcmst
GO

PRINT N'END Drop some view for TM'
GO