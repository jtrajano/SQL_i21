CREATE TABLE [dbo].[tblGLImportCSVLog](
	[intImportLogId] [int] IDENTITY(1,1) NOT NULL,
	[dtmDate] [datetime] NULL,
	[intEntityId] [int] NULL,
	[strVersion] [nvarchar](20) COLLATE Latin1_General_CI_AS NULL ,
	[strEvent] [nvarchar](20) COLLATE Latin1_General_CI_AS NULL ,
	[strMachine] [nvarchar](40) COLLATE Latin1_General_CI_AS NULL ,
 CONSTRAINT [PK_tblGLImportCSVLog] PRIMARY KEY CLUSTERED 
(
	[intImportLogId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

