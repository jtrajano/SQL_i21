IF EXISTS(SELECT TOP 1 1 FROM sys.objects WHERE [name] = N'trgCMBankTransaction' AND [type] = 'TR')
	EXEC('DISABLE TRIGGER dbo.trgCMBankTransaction ON tblCMBankTransaction')
IF EXISTS(SELECT TOP 1 1 FROM sys.objects WHERE [name] = N'trgCMBankTransactionDetail' AND [type] = 'TR')
	EXEC('DISABLE TRIGGER dbo.trgCMBankTransactionDetail ON tblCMBankTransactionDetail')
