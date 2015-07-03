CREATE TABLE [dbo].[tblPRCompanyPreference](
	[intCompanyPreferenceId] [int] IDENTITY(1,1) NOT NULL,
	[intBankAccountId] [int] NULL,
	[strLiabilityAccount] [int] NULL,
	[strExpenseAccount] [nvarchar](50) COLLATE Latin1_General_CI_AS NULL,
	[intTypeEarningId] [int] NULL,
	[strAccountId] [int] NULL,
	[strTimeOff] [NVARCHAR](50) COLLATE Latin1_General_CI_AS NULL,
	[intConcurrencyId] [int] NULL,
 CONSTRAINT [PK_tblPRCompanyPreference1] PRIMARY KEY CLUSTERED 
(
	[intCompanyPreferenceId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

ALTER TABLE [dbo].[tblPRCompanyPreference] ADD  CONSTRAINT [DF_tblPRCompanyPreference1_intConcurrencyId]  DEFAULT ((1)) FOR [intConcurrencyId]
GO
