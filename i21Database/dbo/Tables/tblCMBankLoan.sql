
CREATE TABLE [dbo].[tblCMBankLoan](
	[strBankLoanId] [nvarchar](20)  COLLATE Latin1_General_CI_AS NOT NULL,
	[intBankLoanId] [int] IDENTITY(1,1) NOT NULL,
	[dtmOpened] [date] NOT NULL,
	[dtmMaturity] [date] NOT NULL,
	[dtmEntered] [datetime] NOT NULL,
	[decAnnualInterest] [decimal](8, 4) NOT NULL,
	[ysnOpen] [bit] NOT NULL,
	[strComments] [nvarchar](800) COLLATE Latin1_General_CI_AS NULL,
	[intConcurrencyId] [int] NULL,
	[dblLoanAmount] [decimal](18, 6) NULL,
	[intCompanyLocationId] [int] NULL,
 CONSTRAINT [PK_tblBankLoan] PRIMARY KEY CLUSTERED 
(
	[intBankLoanId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 70) ON [PRIMARY]
) ON [PRIMARY]
GO

CREATE TRIGGER [dbo].[trgBankLoan]
   ON  [dbo].[tblCMBankLoan]
   AFTER INSERT
AS 
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	UPDATE BL
	SET strBankLoanId = 'BLN-' + CAST(BL.intBankLoanId AS NVARCHAR(10))
	FROM tblCMBankLoan BL JOIN
	inserted I on I.intBankLoanId = BL.intBankLoanId
	--SELECT IDENT_CURRENT('Employees') + IDENT_INCR('Employees')

    -- Insert statements for trigger here

END
