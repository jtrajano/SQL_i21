CREATE TABLE [dbo].[tblCMResponsiblePartyMatching](
	[intResponsiblePartyMatchingId] [int] IDENTITY(1,1) NOT NULL,
	[strType] [nvarchar](100) COLLATE Latin1_General_CI_AS NULL,
	[strDescriptionContains] [nvarchar](100) COLLATE Latin1_General_CI_AS NULL,
	[strAccountNumberContains] [nvarchar](100) COLLATE Latin1_General_CI_AS NULL,
	[strReferenceContains] [nvarchar](100) COLLATE Latin1_General_CI_AS NULL,
	[strAction] [nvarchar](30) COLLATE Latin1_General_CI_AS NULL,
	[intGLLocationSegment] [int] NOT NULL,
	[intBankId] [int] NOT NULL,
	[intBankOffsetId] [int] NOT NULL,
	[intGLPrimarySegment] [int] NOT NULL,
	[intConcurrencyId] [int] NOT NULL,
 CONSTRAINT [PK_tblCMResponsiblePartyMatching] PRIMARY KEY CLUSTERED 
(
	[intResponsiblePartyMatchingId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[tblCMResponsiblePartyMatching] ADD  DEFAULT ((1)) FOR [intConcurrencyId]
GO

ALTER TABLE [dbo].[tblCMResponsiblePartyMatching]  WITH CHECK ADD  CONSTRAINT [FK_tblCMResponsiblePartyMatching_tblCMBank] FOREIGN KEY([intBankId])
REFERENCES [dbo].[tblCMBank] ([intBankId])
GO

ALTER TABLE [dbo].[tblCMResponsiblePartyMatching] CHECK CONSTRAINT [FK_tblCMResponsiblePartyMatching_tblCMBank]
GO

ALTER TABLE [dbo].[tblCMResponsiblePartyMatching]  WITH CHECK ADD  CONSTRAINT [FK_tblCMResponsiblePartyMatching_tblCMBank1] FOREIGN KEY([intBankOffsetId])
REFERENCES [dbo].[tblCMBank] ([intBankId])
GO

ALTER TABLE [dbo].[tblCMResponsiblePartyMatching] CHECK CONSTRAINT [FK_tblCMResponsiblePartyMatching_tblCMBank1]
GO

ALTER TABLE [dbo].[tblCMResponsiblePartyMatching]  WITH CHECK ADD  CONSTRAINT [FK_tblCMResponsiblePartyMatching_tblCMResponsiblePartyMatching] FOREIGN KEY([intResponsiblePartyMatchingId])
REFERENCES [dbo].[tblCMResponsiblePartyMatching] ([intResponsiblePartyMatchingId])
GO

ALTER TABLE [dbo].[tblCMResponsiblePartyMatching] CHECK CONSTRAINT [FK_tblCMResponsiblePartyMatching_tblCMResponsiblePartyMatching]
GO

ALTER TABLE [dbo].[tblCMResponsiblePartyMatching]  WITH CHECK ADD  CONSTRAINT [FK_tblCMResponsiblePartyMatching_tblGLAccountSegment] FOREIGN KEY([intGLLocationSegment])
REFERENCES [dbo].[tblGLAccountSegment] ([intAccountSegmentId])
GO

ALTER TABLE [dbo].[tblCMResponsiblePartyMatching] CHECK CONSTRAINT [FK_tblCMResponsiblePartyMatching_tblGLAccountSegment]
GO

