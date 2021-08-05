
CREATE TABLE [dbo].[tblFAImportLog](
	[intImportLogId] [int] IDENTITY(1,1) NOT NULL,
	[dtmDate] [datetime] NULL,
	[strVersion] [nvarchar](20) COLLATE Latin1_General_CI_AS NULL,
	[intEntityId] [int] NULL,
 CONSTRAINT [PK_tblFAImportLog] PRIMARY KEY CLUSTERED 
(
	[intImportLogId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
