
CREATE TABLE [dbo].[tblCMEFTNumbers](
	[intId] [int] IDENTITY(1,1) NOT NULL,
	[intEFTNoId] [int] NOT NULL,
    [intBankAccountId] INT NOT NULL,
	[strProcessType] NVARCHAR(40) COLLATE Latin1_General_CI_AS,
	[intTransactionId] [int]  NULL,
 CONSTRAINT [PK_tblCMEFTNumbers] PRIMARY KEY CLUSTERED 
(
	[intId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

