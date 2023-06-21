CREATE TABLE tblGLIntraCompanyConfig
(
    intIntraCompanyConfigId INT IDENTITY (1,1),
    intParentCompanySegmentId INT NOT NULL,
    intTargetCompanySegmentId INT NOT NULL,
    intDueFromAccountId INT NOT NULL,
    intDueToAccountId INT NOT NULL,
    intConcurrencyId INT NULL,
	CONSTRAINT [PK_tblGLIntraCompanyConfig] PRIMARY KEY CLUSTERED (intIntraCompanyConfigId ASC),
    CONSTRAINT UNIQUE_PARENT_TARGET_tblGLIntraCompanyConfig UNIQUE (intParentCompanySegmentId,intTargetCompanySegmentId)
)
GO

ALTER TABLE [dbo].[tblGLIntraCompanyConfig]  WITH CHECK ADD  CONSTRAINT [FK_tblGLIntraCompanyConfig_tblGLAccount_DueFrom] FOREIGN KEY([intDueFromAccountId])
REFERENCES [dbo].[tblGLAccount] ([intAccountId])
GO

ALTER TABLE [dbo].[tblGLIntraCompanyConfig] CHECK CONSTRAINT [FK_tblGLIntraCompanyConfig_tblGLAccount_DueFrom]
GO

ALTER TABLE [dbo].[tblGLIntraCompanyConfig]  WITH CHECK ADD  CONSTRAINT [FK_tblGLIntraCompanyConfig_tblGLAccount_DueTo] FOREIGN KEY([intDueToAccountId])
REFERENCES [dbo].[tblGLAccount] ([intAccountId])
GO

ALTER TABLE [dbo].[tblGLIntraCompanyConfig] CHECK CONSTRAINT [FK_tblGLIntraCompanyConfig_tblGLAccount_DueTo]
GO

ALTER TABLE [dbo].[tblGLIntraCompanyConfig]  WITH CHECK ADD  CONSTRAINT [FK_tblGLIntraCompanyConfig_tblGLAccountSegment_ParentCompany] FOREIGN KEY([intParentCompanySegmentId])
REFERENCES [dbo].[tblGLAccountSegment] ([intAccountSegmentId])
GO

ALTER TABLE [dbo].[tblGLIntraCompanyConfig] CHECK CONSTRAINT [FK_tblGLIntraCompanyConfig_tblGLAccountSegment_ParentCompany]
GO

ALTER TABLE [dbo].[tblGLIntraCompanyConfig]  WITH CHECK ADD  CONSTRAINT [FK_tblGLIntraCompanyConfig_tblGLAccountSegment_TargetCompany] FOREIGN KEY([intTargetCompanySegmentId])
REFERENCES [dbo].[tblGLAccountSegment] ([intAccountSegmentId])
GO

ALTER TABLE [dbo].[tblGLIntraCompanyConfig] CHECK CONSTRAINT [FK_tblGLIntraCompanyConfig_tblGLAccountSegment_TargetCompany]
GO

