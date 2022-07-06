
CREATE TABLE [dbo].[tblGLConsolidateLog](
	[intConsolidateLogId] [int] IDENTITY(1,1) NOT NULL,
	[ysnFiscalOpen] [bit] NULL,
	[ysnHasUnposted] [bit] NULL,
	[ysnSuccess] [bit] NOT NULL,
	[dtmDateEntered] [datetime] NOT NULL,
	[dtmDate] [date] NOT NULL,
	[intFiscalPeriodId] [int] NOT NULL,
	[intConcurrencyId] [int] NOT NULL,
	[intSubsidiaryCompanyId] [int] NOT NULL,
	[intEntityId] [int] NOT NULL,
	[intRowInserted] [int] NULL,
	[strPeriod] NVARCHAR(40) NOT NULL,
	[strComment] [nvarchar](800) NULL,
 CONSTRAINT [PK_tblGLConsolidateLog] PRIMARY KEY CLUSTERED 
(
	[intConsolidateLogId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[tblGLConsolidateLog] ADD  CONSTRAINT [FK_tblGLConsolidateLog_tblGLSubsidiaryCompany] FOREIGN KEY([intSubsidiaryCompanyId])
REFERENCES [dbo].[tblGLSubsidiaryCompany] ([intSubsidiaryCompanyId])
GO

ALTER TABLE [dbo].[tblGLConsolidateLog] CHECK CONSTRAINT [FK_tblGLConsolidateLog_tblGLSubsidiaryCompany]
GO

