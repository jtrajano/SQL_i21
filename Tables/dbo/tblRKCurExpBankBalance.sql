
CREATE TABLE [dbo].[tblRKCurExpBankBalance]
(
	[intCurExpBankBalanceId] INT IDENTITY(1,1) NOT NULL,	
	[intConcurrencyId] INT NOT NULL, 
	[intCurrencyExposureId] INT NOT NULL, 
	[intBankId] int NULL,
	[intBankAccountId] int NULL,
	[dblAmount]  NUMERIC(24, 6) NULL,

	CONSTRAINT [PK_tblRKCurExpBankBalance_intCurExpBankBalanceId] PRIMARY KEY (intCurExpBankBalanceId),   
	CONSTRAINT [FK_tblRKCurExpBankBalance_tblRKCurrencyExposure_intCurrencyExposureId] FOREIGN KEY([intCurrencyExposureId])REFERENCES [dbo].[tblRKCurrencyExposure] (intCurrencyExposureId) ON DELETE CASCADE,  
	CONSTRAINT [FK_tblRKCurExpBankBalance_tblCMBank_intBankId] FOREIGN KEY(intBankId)REFERENCES [dbo].[tblCMBank] (intBankId),
	CONSTRAINT [FK_tblRKCurExpBankBalance_tblCMBankAccount_intBankAccountId] FOREIGN KEY(intBankAccountId)REFERENCES [dbo].[tblCMBankAccount] (intBankAccountId)	
)