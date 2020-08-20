CREATE TABLE [dbo].[tblPRCompanyPreference](
	[intCompanyPreferenceId] [int] IDENTITY(1,1) NOT NULL,
	[intBankAccountId] [int] NULL,
	[intLiabilityAccount] [int] NULL,
	[intExpenseAccount] [int] NULL,
	[intEarningAccountId] [int] NULL,
	[intDeductionAccountId] [int] NULL,
	[ysnMaskEmployeeName] BIT NOT NULL DEFAULT ((0)), 
	[ysnPreventNegativeTimeOff] BIT NOT NULL DEFAULT ((0)), 
	[dtmLastTimeOffAdjustmentReset] DATETIME NULL,
	[intCommissionEarningId] [int] NULL,
	[strWH32BaseAddress] [nvarchar](150) NULL,
	[intConcurrencyId] [int] NULL,
    CONSTRAINT [PK_tblPRCompanyPreference] PRIMARY KEY CLUSTERED 
(
	[intCompanyPreferenceId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY], 
    CONSTRAINT [FK_tblPRCompanyPreference_tblGLAccount_Liability] FOREIGN KEY ([intLiabilityAccount]) REFERENCES [tblGLAccount]([intAccountId]),
	CONSTRAINT [FK_tblPRCompanyPreference_tblGLAccount_Expense] FOREIGN KEY ([intExpenseAccount]) REFERENCES [tblGLAccount]([intAccountId]),
	CONSTRAINT [FK_tblPRCompanyPreference_tblGLAccount_Earning] FOREIGN KEY ([intEarningAccountId]) REFERENCES [tblGLAccount]([intAccountId]),
	CONSTRAINT [FK_tblPRCompanyPreference_tblGLAccount_Deduction] FOREIGN KEY ([intDeductionAccountId]) REFERENCES [tblGLAccount]([intAccountId]),
	CONSTRAINT [FK_tblPRCompanyPreference_tblPRTypeEarning] FOREIGN KEY ([intCommissionEarningId]) REFERENCES [tblPRTypeEarning]([intTypeEarningId])
) ON [PRIMARY]

GO

ALTER TABLE [dbo].[tblPRCompanyPreference] ADD  CONSTRAINT [DF_tblPRCompanyPreference_intConcurrencyId]  DEFAULT ((1)) FOR [intConcurrencyId]
GO
