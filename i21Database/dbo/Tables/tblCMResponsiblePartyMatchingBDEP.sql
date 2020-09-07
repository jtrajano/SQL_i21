CREATE TABLE [dbo].[tblCMResponsiblePartyMatchingBDEP](
	[intResponsiblePartyMatchingBDEPId] [int] IDENTITY(1,1) NOT NULL,
	[intGLLocationSegment] [int] NOT NULL,
	[strContains] [nvarchar](100) COLLATE Latin1_General_CI_AS NOT NULL,
	[intConcurrencyId] [int] NOT NULL,
 CONSTRAINT [PK_tblCMResponsiblePartyMatchingBDEP] PRIMARY KEY CLUSTERED 
(
	[intResponsiblePartyMatchingBDEPId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[tblCMResponsiblePartyMatchingBDEP] ADD  CONSTRAINT [DF__tblCMResp__intCo__13ECCA1E]  DEFAULT ((1)) FOR [intConcurrencyId]
GO

ALTER TABLE [dbo].[tblCMResponsiblePartyMatchingBDEP]  WITH CHECK ADD  CONSTRAINT [FK_tblCMResponsiblePartyMatchingBDEP_tblGLAccountSegment] FOREIGN KEY([intGLLocationSegment])
REFERENCES [dbo].[tblGLAccountSegment] ([intAccountSegmentId])
GO

ALTER TABLE [dbo].[tblCMResponsiblePartyMatchingBDEP] CHECK CONSTRAINT [FK_tblCMResponsiblePartyMatchingBDEP_tblGLAccountSegment]
GO

