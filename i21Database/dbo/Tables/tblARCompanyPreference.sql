CREATE TABLE [dbo].[tblARCompanyPreference]
(
	[intCompanyPreferenceId]		INT NOT NULL PRIMARY KEY IDENTITY, 
    [intARAccountId]				INT NULL, 
    [intDiscountAccountId]			INT NULL,
	[intWriteOffAccountId]			INT NULL,
	[intInterestIncomeAccountId]	INT NULL,
	[intDeferredRevenueAccountId]	INT NULL,
	[intServiceChargeAccountId]		INT NULL,
	[strServiceChargeCalculation]	NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	[strServiceChargeFrequency]		NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	[intConversionAccountId]		INT NULL,
	[ysnLineItemAccountUpdate]		BIT NULL DEFAULT 0,
	[intConcurrencyId]				INT NOT NULL DEFAULT 1,
	CONSTRAINT [FK_tblARCompanyPreference_tblGLAccount_intARAccountId] FOREIGN KEY ([intARAccountId]) REFERENCES [dbo].[tblGLAccount] ([intAccountId]),
	CONSTRAINT [FK_tblARCompanyPreference_tblGLAccount_intDiscountAccountId] FOREIGN KEY ([intDiscountAccountId]) REFERENCES [dbo].[tblGLAccount] ([intAccountId]),
	CONSTRAINT [FK_tblARCompanyPreference_tblGLAccount_intWriteOffAccountId] FOREIGN KEY ([intWriteOffAccountId]) REFERENCES [dbo].[tblGLAccount] ([intAccountId]),
	CONSTRAINT [FK_tblARCompanyPreference_tblGLAccount_intInterestIncomeAccountId] FOREIGN KEY ([intInterestIncomeAccountId]) REFERENCES [dbo].[tblGLAccount] ([intAccountId]),
	CONSTRAINT [FK_tblARCompanyPreference_tblGLAccount_intDeferredRevenueAccountId] FOREIGN KEY ([intDeferredRevenueAccountId]) REFERENCES [dbo].[tblGLAccount] ([intAccountId]),
	CONSTRAINT [FK_tblARCompanyPreference_tblGLAccount_intServiceChargeAccountId] FOREIGN KEY ([intServiceChargeAccountId]) REFERENCES [dbo].[tblGLAccount] ([intAccountId]),
	CONSTRAINT [FK_tblARCompanyPreference_tblGLAccount_intConversionAccountId] FOREIGN KEY ([intConversionAccountId]) REFERENCES [dbo].[tblGLAccount] ([intAccountId])
)
