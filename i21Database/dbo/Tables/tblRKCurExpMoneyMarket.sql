CREATE TABLE [dbo].[tblRKCurExpMoneyMarket]
(
	[intCurExpMoneyMarketId] INT IDENTITY(1,1) NOT NULL,	
	[intConcurrencyId] INT NOT NULL, 
	[intCurrencyExposureId] INT NOT NULL, 
	[intBankId] int NULL,	
	[dtmDateOpened] datetime,
	[strDescription] NVARCHAR(250) COLLATE Latin1_General_CI_AS NULL,
	[dblAmount] NUMERIC(24, 6) NULL,
	[dblAnnualInterest] NUMERIC(24, 6) NULL,
	[dblInterestAmount] NUMERIC(24, 6) NULL,
	[dtmMaturityDate] datetime,

	CONSTRAINT [PK_tblRKCurExpMoneyMarket_intCurExpMoneyMarketId] PRIMARY KEY (intCurExpMoneyMarketId),   
	CONSTRAINT [FK_tblRKCurExpMoneyMarket_tblRKCurrencyExposure_intCurrencyExposureId] FOREIGN KEY([intCurrencyExposureId])REFERENCES [dbo].[tblRKCurrencyExposure] (intCurrencyExposureId) ON DELETE CASCADE,  
	CONSTRAINT [FK_tblRKCurExpMoneyMarket_tblCMBank_intBankId] FOREIGN KEY(intBankId)REFERENCES [dbo].[tblCMBank] (intBankId)
)