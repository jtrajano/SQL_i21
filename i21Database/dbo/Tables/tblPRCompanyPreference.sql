CREATE TABLE [dbo].[tblPRCompanyPreference](
	[intCompanyPreferenceId] [int] IDENTITY(1,1) NOT NULL,
	[intBankAccountId] [int] NULL,
	[intLiabilityAccount] [int] NULL,
	[intExpenseAccount] [int] NULL,
	[intEarningAccountId] [int] NULL,
	[intDeductionAccountId] [int] NULL,
	[intConcurrencyId] [int] NULL,
 CONSTRAINT [PK_tblPRCompanyPreference] PRIMARY KEY CLUSTERED 
(
	[intCompanyPreferenceId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

ALTER TABLE [dbo].[tblPRCompanyPreference] ADD  CONSTRAINT [DF_tblPRCompanyPreference_intConcurrencyId]  DEFAULT ((1)) FOR [intConcurrencyId]
GO
