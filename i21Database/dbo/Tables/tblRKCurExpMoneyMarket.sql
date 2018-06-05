CREATE TABLE [dbo].[tblRKCurExpMoneyMarket]
(
	[intCurExpMoneyMarketId] INT IDENTITY(1,1) NOT NULL,	
	[intConcurrencyId] INT NOT NULL, 
	[intCurrencyExposureId] INT NOT NULL, 
	[intBankId] int NULL,	
	[dblAmount]  NUMERIC(24, 6) NULL,
	[intCurrencyId] int NULL,
	[intCompanyId] int null,   

	CONSTRAINT [PK_tblRKCurExpMoneyMarket_intCurExpMoneyMarketId] PRIMARY KEY (intCurExpMoneyMarketId),   
	CONSTRAINT [FK_tblRKCurExpMoneyMarket_tblRKCurrencyExposure_intCurrencyExposureId] FOREIGN KEY([intCurrencyExposureId])REFERENCES [dbo].[tblRKCurrencyExposure] (intCurrencyExposureId) ON DELETE CASCADE,  
	CONSTRAINT [FK_tblRKCurExpMoneyMarket_tblCMBank_intBankId] FOREIGN KEY(intBankId)REFERENCES [dbo].[tblCMBank] (intBankId),
	CONSTRAINT [FK_tblRKCurExpMoneyMarket_tblSMCurrency_intCurrencyId] FOREIGN KEY(intCurrencyId)REFERENCES [dbo].[tblSMCurrency] (intCurrencyID)
)