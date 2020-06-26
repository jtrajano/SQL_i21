CREATE TABLE [dbo].[tblCMResponsiblePartyTaskDetail](
	[intTaskDetailId] [int] IDENTITY(1,1) NOT NULL,
	[intTaskId] [int] NULL,
	[intTransactionId] [int] NULL,
	[dblAmount] [decimal](18, 6) NULL,
	[intGLAccountId] [int] NULL,
	[strDescription] [nvarchar](200) COLLATE Latin1_General_CI_AS NULL,
	[dtmDate] [datetime] NULL,
	[intBankAccountId] [int] NULL,
	[intEntityId] [int] NULL,
	[intConcurrencyId] [int] NULL
) ON [PRIMARY]
GO

