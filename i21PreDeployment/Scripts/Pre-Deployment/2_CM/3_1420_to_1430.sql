
PRINT N'BEGIN CASH MANAGEMENT DELETE PATH: 14.2 to 14.3'

-- Drop the view (apchkmst) because of the schema change in tblCMBankTransaction.
PRINT N'Dropping View: [dbo].[apchkmst]...';
GO
	IF EXISTS(select top 1 1 from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = 'apchkmst')
		DROP VIEW apchkmst
GO

PRINT N'END CASH MANAGEMENT DELETE PATH: 14.2 to 14.3'