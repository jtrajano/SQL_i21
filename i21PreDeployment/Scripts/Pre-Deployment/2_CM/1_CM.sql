
IF EXISTS(select top 1 1 from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = 'apcbkmst')
	DROP VIEW apcbkmst


IF EXISTS(select 1  from INFORMATION_SCHEMA.TABLES where TABLE_NAME = N'apcbkmst' and TABLE_TYPE = N'BASE TABLE')
BEGIN
	--Drop apcbkmst_origin if exist in preparation for sp_rename
	IF EXISTS(select 1  from INFORMATION_SCHEMA.TABLES where TABLE_NAME = N'apcbkmst_origin' and TABLE_TYPE = N'BASE TABLE')
	BEGIN
		DROP TABLE apcbkmst_origin
	END

	EXEC sp_rename 'dbo.apcbkmst', 'apcbkmst_origin'
END
GO

IF EXISTS(select 1  from INFORMATION_SCHEMA.TABLES where TABLE_NAME = N'apchkmst' and TABLE_TYPE = N'BASE TABLE')
BEGIN
	--Drop apchkmst_origin if exist in preparation for sp_rename
	IF EXISTS(select 1  from INFORMATION_SCHEMA.TABLES where TABLE_NAME = N'apchkmst_origin' and TABLE_TYPE = N'BASE TABLE')
	BEGIN
		DROP TABLE apchkmst_origin
	END

	EXEC sp_rename 'dbo.apchkmst', 'apchkmst_origin'
END
GO

--RENAME Bank Transfer columns 
IF COL_LENGTH('tblCMBankTransfer', 'dblRate') IS NOT NULL
BEGIN
	EXEC sp_rename 'dbo.tblCMBankTransfer.dblRate', 'dblRateAmountTo', 'COLUMN';  
	EXEC sp_rename 'dbo.tblCMBankTransfer.dblHistoricRate', 'dblRateAmountFrom', 'COLUMN';  
END