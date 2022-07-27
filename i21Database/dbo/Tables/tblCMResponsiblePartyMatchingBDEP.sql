CREATE TABLE [dbo].[tblCMResponsiblePartyMatchingBDEP](
	[intResponsiblePartyMatchingBDEPId] [int] IDENTITY(1,1) NOT NULL,
	[intLocationSegmentId] [int] NULL,
	[intAccountId] INT NULL,
	[strContains] [nvarchar](100) COLLATE Latin1_General_CI_AS NULL,
	[intConcurrencyId] [int] NOT NULL,
	[intResponsiblePartyMatchingId] [int] NOT NULL,
 CONSTRAINT [PK_tblCMResponsiblePartyMatchingBDEP] PRIMARY KEY CLUSTERED
(
	[intResponsiblePartyMatchingBDEPId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[tblCMResponsiblePartyMatchingBDEP] ADD  CONSTRAINT [DF__tblCMResp__intCo__13ECCA1E]  DEFAULT ((1)) FOR [intConcurrencyId]
GO

ALTER TABLE [dbo].[tblCMResponsiblePartyMatchingBDEP]  WITH CHECK ADD  CONSTRAINT [FK_tblCMResponsiblePartyMatchingBDEP_tblGLAccountSegment] FOREIGN KEY([intResponsiblePartyMatchingId])
REFERENCES [dbo].[tblCMResponsiblePartyMatching] ([intResponsiblePartyMatchingId])
ON DELETE CASCADE
GO

ALTER TABLE [dbo].[tblCMResponsiblePartyMatchingBDEP] CHECK CONSTRAINT [FK_tblCMResponsiblePartyMatchingBDEP_tblGLAccountSegment]
GO

