CREATE TABLE [dbo].[tblCMBankLoan](
	[strBankLoanId] [nvarchar](20) COLLATE Latin1_General_CI_AS NOT NULL,
	[intBankLoanId] [int] IDENTITY(1,1) NOT NULL,
	[intBankAccountId] [int] NOT NULL,
	[dtmOpened] [date] NOT NULL,
	[dtmMaturity] [date] NOT NULL,
	[dtmEntered] [datetime] NOT NULL,
	[decAnnualInterest] [decimal](8, 4) NOT NULL,
	[ysnOpen] [bit] NOT NULL,
	[strComments] [nvarchar](800) COLLATE Latin1_General_CI_AS NULL,
	[intConcurrencyId] [int] NULL,
 CONSTRAINT [PK_tblBankLoan] PRIMARY KEY CLUSTERED 
(
	[intBankLoanId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[tblCMBankLoan]  WITH CHECK ADD  CONSTRAINT [FK_tblBankLoan_tblCMBank] FOREIGN KEY([intBankAccountId])
REFERENCES [dbo].[tblCMBankAccount] ([intBankAccountId])
GO

ALTER TABLE [dbo].[tblCMBankLoan] CHECK CONSTRAINT [FK_tblBankLoan_tblCMBank]
GO

