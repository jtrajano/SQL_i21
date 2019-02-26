
CREATE TABLE [dbo].[tblCMBankLoan](
	[strBankLoanId] [nvarchar](20) NOT NULL,
	[intBankLoanId] [int] IDENTITY(1,1) NOT NULL,
	[dtmOpened] [date] NOT NULL,
	[dtmMaturity] [date] NOT NULL,
	[dtmEntered] [datetime] NOT NULL,
	[decAnnualInterest] [decimal](8, 4) NOT NULL,
	[ysnOpen] [bit] NOT NULL,
	[strComments] [nvarchar](800) NULL,
	[intConcurrencyId] [int] NULL,
	[dblLoanAmount] [decimal](18, 6) NULL,
 CONSTRAINT [PK_tblBankLoan] PRIMARY KEY CLUSTERED 
(
	[intBankLoanId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 70) ON [PRIMARY]
) ON [PRIMARY]
GO

