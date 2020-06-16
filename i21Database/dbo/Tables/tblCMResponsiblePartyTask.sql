CREATE TABLE [dbo].[tblCMResponsiblePartyTask](
	[intTaskId] [int] IDENTITY(1,1) NOT NULL,
	[intResponsibleBankAccountId] [int] NOT NULL,
	[intEntityId] INT,
	[strTransactionId] [nvarchar](20) COLLATE Latin1_General_CI_AS NOT NULL,
	[dtmDateCreated] [datetime] NOT NULL,
	[intConcurrencyId] [int] NOT NULL,
	[ysnStatus] [bit] NULL,
    [dblAmount] decimal(18,6),
	[strBankStatementImportId] NVARCHAR(20),
	[intBankStatementImportId] INT
 CONSTRAINT [PK_tblCMResponsiblePartyTask] PRIMARY KEY CLUSTERED 
(
	[intTaskId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[tblCMResponsiblePartyTask] ADD  CONSTRAINT [DF_tblCMResponsiblePartyTask_intConcurrencyId]  
DEFAULT (1) FOR [intConcurrencyId]
GO

ALTER TABLE [dbo].[tblCMResponsiblePartyTask] ADD  CONSTRAINT [DF_tblCMResponsiblePartyTask_dtmDateCreated]  
DEFAULT (getdate()) FOR [dtmDateCreated]
GO

ALTER TABLE [dbo].[tblCMResponsiblePartyTask]  WITH CHECK ADD  CONSTRAINT [FK_tblCMResponsiblePartyTask_tblCMBankAccount] FOREIGN KEY([intResponsibleBankAccountId])
REFERENCES [dbo].[tblCMBankAccount] ([intBankAccountId])
GO

ALTER TABLE [dbo].[tblCMResponsiblePartyTask] CHECK CONSTRAINT [FK_tblCMResponsiblePartyTask_tblCMBankAccount]
GO

