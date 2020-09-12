CREATE TABLE [dbo].[tblCMResponsiblePartyMatching](
	[intResponsiblePartyMatchingId] [int] IDENTITY(1,1) NOT NULL,
	[strType] [nvarchar](100) COLLATE Latin1_General_CI_AS NULL,
	[strDescriptionContains] [nvarchar](100) COLLATE Latin1_General_CI_AS NULL,
	[strAccountNumberContains] [nvarchar](100) COLLATE Latin1_General_CI_AS NULL,
	[strReferenceContains] [nvarchar](100) COLLATE Latin1_General_CI_AS NULL,
	[intActionId] [int] NOT NULL,
	[intLocationSegmentId] [int] NULL,
	[intPrimaryBankId] [int] NULL,
	[intOffsetBankId] [int] NULL,
	[intPrimarySegmentId] [int] NULL,
	[intConcurrencyId] [int] NOT NULL,
 CONSTRAINT [PK_tblCMResponsiblePartyMatching] PRIMARY KEY CLUSTERED 
(
	[intResponsiblePartyMatchingId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[tblCMResponsiblePartyMatching] ADD  CONSTRAINT [DF__tblCMResp__intCo__345999B0]  DEFAULT ((1)) FOR [intConcurrencyId]
GO

ALTER TABLE [dbo].[tblCMResponsiblePartyMatching]  WITH CHECK ADD  CONSTRAINT [FK_tblCMResponsiblePartyMatching_tblCMBank] FOREIGN KEY([intPrimaryBankId])
REFERENCES [dbo].[tblCMBankAccount] ([intBankAccountId])
GO

ALTER TABLE [dbo].[tblCMResponsiblePartyMatching] CHECK CONSTRAINT [FK_tblCMResponsiblePartyMatching_tblCMBank]
GO

ALTER TABLE [dbo].[tblCMResponsiblePartyMatching]  WITH CHECK ADD  CONSTRAINT [FK_tblCMResponsiblePartyMatching_tblCMBank1] FOREIGN KEY([intOffsetBankId])
REFERENCES [dbo].[tblCMBankAccount] ([intBankAccountId])
GO

ALTER TABLE [dbo].[tblCMResponsiblePartyMatching] CHECK CONSTRAINT [FK_tblCMResponsiblePartyMatching_tblCMBank1]
GO

ALTER TABLE [dbo].[tblCMResponsiblePartyMatching]  WITH CHECK ADD  CONSTRAINT [FK_tblCMResponsiblePartyMatching_tblCMResponsiblePartyMatching] FOREIGN KEY([intResponsiblePartyMatchingId])
REFERENCES [dbo].[tblCMResponsiblePartyMatching] ([intResponsiblePartyMatchingId])
GO

ALTER TABLE [dbo].[tblCMResponsiblePartyMatching] CHECK CONSTRAINT [FK_tblCMResponsiblePartyMatching_tblCMResponsiblePartyMatching]
GO

ALTER TABLE [dbo].[tblCMResponsiblePartyMatching]  WITH CHECK ADD  CONSTRAINT [FK_tblCMResponsiblePartyMatching_tblGLAccountSegment] FOREIGN KEY([intLocationSegmentId])
REFERENCES [dbo].[tblGLAccountSegment] ([intAccountSegmentId])
GO

ALTER TABLE [dbo].[tblCMResponsiblePartyMatching] CHECK CONSTRAINT [FK_tblCMResponsiblePartyMatching_tblGLAccountSegment]
GO
