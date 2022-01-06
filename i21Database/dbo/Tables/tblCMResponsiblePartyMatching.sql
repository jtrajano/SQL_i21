CREATE TABLE [dbo].[tblCMResponsiblePartyMatching](
	[intResponsiblePartyMatchingId] [int] IDENTITY(1,1) NOT NULL,
	[strType] [nvarchar](100)  COLLATE Latin1_General_CI_AS NOT NULL,
	[strDescriptionContains] [nvarchar](100)  COLLATE Latin1_General_CI_AS NULL,
	[strAccountNumberContains] [nvarchar](100)  COLLATE Latin1_General_CI_AS NULL,
	[strReferenceContains] [nvarchar](100)  COLLATE Latin1_General_CI_AS NULL,
	[intActionId] [int] NOT NULL,
	[intPrimaryBankId] [int] NULL,
	[intOffsetBankId] [int] NULL,
	[intPrimaryAccountId] [int] NULL,
	[intConcurrencyId] [int] NOT NULL,
	[strLocationSearch] [nvarchar](20)  COLLATE Latin1_General_CI_AS NULL,
 CONSTRAINT [PK_tblCMResponsiblePartyMatching] PRIMARY KEY CLUSTERED
(
	[intResponsiblePartyMatchingId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[tblCMResponsiblePartyMatching] ADD  CONSTRAINT [DF__tblCMResp__intCo__345999B0]  DEFAULT ((1)) FOR [intConcurrencyId]
GO

ALTER TABLE [dbo].[tblCMResponsiblePartyMatching] ADD  CONSTRAINT [FK_tblCMResponsiblePartyMatching_tblCMBankAccount] FOREIGN KEY([intOffsetBankId])
REFERENCES [dbo].[tblCMBankAccount] ([intBankAccountId])
GO

ALTER TABLE [dbo].[tblCMResponsiblePartyMatching] CHECK CONSTRAINT [FK_tblCMResponsiblePartyMatching_tblCMBankAccount]
GO

ALTER TABLE [dbo].[tblCMResponsiblePartyMatching] ADD  CONSTRAINT [FK_tblCMResponsiblePartyMatching_tblCMBankAccount1] FOREIGN KEY([intPrimaryBankId])
REFERENCES [dbo].[tblCMBankAccount] ([intBankAccountId])
GO

ALTER TABLE [dbo].[tblCMResponsiblePartyMatching] CHECK CONSTRAINT [FK_tblCMResponsiblePartyMatching_tblCMBankAccount1]
GO

ALTER TABLE [dbo].[tblCMResponsiblePartyMatching] ADD  CONSTRAINT [FK_tblCMResponsiblePartyMatching_tblGLAccount] FOREIGN KEY([intPrimaryAccountId])
REFERENCES [dbo].[tblGLAccount] ([intAccountId])
GO

ALTER TABLE [dbo].[tblCMResponsiblePartyMatching] CHECK CONSTRAINT [FK_tblCMResponsiblePartyMatching_tblGLAccount]
GO