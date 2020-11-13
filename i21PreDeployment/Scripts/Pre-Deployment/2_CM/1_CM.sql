IF EXISTS(SELECT TOP 1 1 FROM sys.objects WHERE [name] = N'trgCMBankTransaction' AND [type] = 'TR')
	EXEC('DISABLE TRIGGER dbo.trgCMBankTransaction ON tblCMBankTransaction')
IF EXISTS(SELECT TOP 1 1 FROM sys.objects WHERE [name] = N'trgCMBankTransactionDetail' AND [type] = 'TR')
	EXEC('DISABLE TRIGGER dbo.trgCMBankTransactionDetail ON tblCMBankTransactionDetail')


IF EXISTS(select 1  from INFORMATION_SCHEMA.TABLES where TABLE_NAME = N'apcbkmst' and TABLE_TYPE = N'BASE TABLE')
BEGIN
	--Drop apcbkmst_origin if exist in preparation for sp_rename
	IF EXISTS(select 1  from INFORMATION_SCHEMA.TABLES where TABLE_NAME = N'apcbkmst_origin' and TABLE_TYPE = N'BASE TABLE')
	BEGIN
		DROP TABLE apcbkmst_origin
	END

	EXEC sp_rename 'apcbkmst', 'apcbkmst_origin'
END
GO

IF EXISTS(select 1  from INFORMATION_SCHEMA.TABLES where TABLE_NAME = N'apchkmst' and TABLE_TYPE = N'BASE TABLE')
BEGIN
	--Drop apchkmst_origin if exist in preparation for sp_rename
	IF EXISTS(select 1  from INFORMATION_SCHEMA.TABLES where TABLE_NAME = N'apchkmst_origin' and TABLE_TYPE = N'BASE TABLE')
	BEGIN
		DROP TABLE apchkmst_origin
	END

	EXEC sp_rename 'apchkmst', 'apchkmst_origin'
END
GO