CREATE TABLE [dbo].[tblFRArchive] (
    [intArchiveId] [int] IDENTITY(1,1) NOT NULL,
	[intReportId] [int] NULL,
	[blbReport] [varbinary](max) NULL,
	[strReportName] [nvarchar](255) NULL,
	[strDescripion] [nvarchar](255) NULL,
	[dtmAsOfDate] [datetime] NULL,
	[dtmAdded] [datetime] DEFAULT (getdate()) NULL,
	[strGUID] [nvarchar](250) NULL,
	[intEntityId] [int] NULL,
	[intConcurrencyId] [int] NOT NULL,
    CONSTRAINT [PK_tblFRArchive] PRIMARY KEY CLUSTERED ([intArchiveId] ASC)
);