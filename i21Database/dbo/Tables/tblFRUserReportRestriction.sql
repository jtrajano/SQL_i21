CREATE TABLE [dbo].[tblFRUserReportRestriction](
	[intRestrictionId] [int] IDENTITY(1,1) NOT NULL,
	[intReportId] [int] NOT NULL,
	[ysnRestriction] [bit] NULL,
	[intEntityId] [int] NOT NULL,
	[intConcurrencyId] [int] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[intRestrictionId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[tblFRUserReportRestriction]  WITH CHECK ADD  CONSTRAINT [FK_tblFRUserReportRestriction_intEntityId_tblSMUserSecurity] FOREIGN KEY([intEntityId])
REFERENCES [dbo].[tblSMUserSecurity] ([intEntityId])
GO

ALTER TABLE [dbo].[tblFRUserReportRestriction] CHECK CONSTRAINT [FK_tblFRUserReportRestriction_intEntityId_tblSMUserSecurity]
GO

