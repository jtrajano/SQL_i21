CREATE TABLE [dbo].[tblFACompanyPreferenceOption]
(
	[intCompanyPreferenceOptionId]	INT IDENTITY(1,1) NOT NULL,
	[intAssetAccountId]				INT NULL,
	[intExpenseAccountId]			INT NULL,
	[intDepreciationAccountId]		INT NULL,
	[intAccumulatedAccountId]		INT NULL,
	[intGainLossAccountId]			INT NULL,
	[intSalesOffsetAccountId]		INT NULL,
    [intConcurrencyId]				INT DEFAULT 1 NOT NULL,

	CONSTRAINT [PK_tblFACompanyPreferenceOption] PRIMARY KEY CLUSTERED ([intCompanyPreferenceOptionId] ASC),
	CONSTRAINT [FK_tblFACompanyPreferenceOption_tblGLAccount1] FOREIGN KEY ([intAssetAccountId]) REFERENCES [dbo].[tblGLAccount] ([intAccountId]),
	CONSTRAINT [FK_tblFACompanyPreferenceOption_tblGLAccount2] FOREIGN KEY ([intExpenseAccountId]) REFERENCES [dbo].[tblGLAccount] ([intAccountId]),
	CONSTRAINT [FK_tblFACompanyPreferenceOption_tblGLAccount3] FOREIGN KEY ([intDepreciationAccountId]) REFERENCES [dbo].[tblGLAccount] ([intAccountId]),
	CONSTRAINT [FK_tblFACompanyPreferenceOption_tblGLAccount4] FOREIGN KEY ([intAccumulatedAccountId]) REFERENCES [dbo].[tblGLAccount] ([intAccountId]),
	CONSTRAINT [FK_tblFACompanyPreferenceOption_tblGLAccount5] FOREIGN KEY ([intSalesOffsetAccountId]) REFERENCES [dbo].[tblGLAccount] ([intAccountId])
)
