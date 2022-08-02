CREATE TABLE [dbo].[tblICLocationBinsReportLog](
	[intLogId] [int] IDENTITY(1,1) NOT NULL,
	[dtmLastRun] [datetime] NULL,
	[ysnRebuilding] [bit] NULL,
	[dtmStart] [datetime] NULL,
	[dtmEnd] [datetime] NULL,
	[intEntityUserSecurityId] [int] NULL,
 CONSTRAINT [PK_tblICLocationBinsReportLog] PRIMARY KEY CLUSTERED 
(
	[intLogId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[tblICLocationBinsReportLog] ADD  DEFAULT ((0)) FOR [ysnRebuilding]
GO
