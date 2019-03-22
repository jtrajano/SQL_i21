CREATE TABLE [dbo].[tblRKCurExpCurrencyContract]
(
	[intCurExpCurrencyContractId] INT IDENTITY(1,1) NOT NULL,	
	[intConcurrencyId] INT NOT NULL, 
	[intCurrencyExposureId] INT NOT NULL, 
	[intFutOptTransactionId] INT NOT NULL, 
	[dtmDate] datetime  NULL,
	[strBuySell] NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL,
	[intBankId] int NULL,	
	[dtmMaturityDate] datetime NULL,
	[strCurrencyPair] NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL,
	[dblAmount]  NUMERIC(24, 6) NULL,	
	[intAmountCurrencyId] int NULL,
	[dblExchangeRate]  NUMERIC(24, 6) NULL,	
	[intExchangeRateCurrencyId] int NULL,
	[dblBalanceAmount]  NUMERIC(24, 6) NULL,	
	[intBalanceAmountCurrencyId] int NULL,
	[intCompanyId] int NULL,   

	CONSTRAINT [PK_tblRKCurExpCurrencyContract_intCurExpCurrencyContractId] PRIMARY KEY (intCurExpCurrencyContractId),   
	CONSTRAINT [FK_tblRKCurExpCurrencyContract_tblRKCurrencyExposure_intCurrencyExposureId] FOREIGN KEY([intCurrencyExposureId])REFERENCES [dbo].[tblRKCurrencyExposure] (intCurrencyExposureId) ON DELETE CASCADE,  
	CONSTRAINT [FK_tblRKCurExpCurrencyContract_tblRKFutOptTransaction_intFutOptTransactionId] FOREIGN KEY(intFutOptTransactionId)REFERENCES [dbo].[tblRKFutOptTransaction] (intFutOptTransactionId),
	CONSTRAINT [FK_tblRKCurExpCurrencyContract_tblCMBank_intBankId] FOREIGN KEY(intBankId)REFERENCES [dbo].[tblCMBank] (intBankId),
	CONSTRAINT [FK_tblRKCurExpCurrencyContract_tblSMCurrency_intAmountCurrencyId] FOREIGN KEY(intAmountCurrencyId)REFERENCES [dbo].[tblSMCurrency] (intCurrencyID),
	CONSTRAINT [FK_tblRKCurExpCurrencyContract_tblSMCurrency_intExchangeRateCurrencyId] FOREIGN KEY(intExchangeRateCurrencyId)REFERENCES [dbo].[tblSMCurrency] (intCurrencyID),
	CONSTRAINT [FK_tblRKCurExpCurrencyContract_tblSMCurrency_intBalanceAmountCurrencyId] FOREIGN KEY(intBalanceAmountCurrencyId)REFERENCES [dbo].[tblSMCurrency] (intCurrencyID)

)