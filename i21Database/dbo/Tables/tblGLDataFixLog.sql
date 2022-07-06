
/* Records Data fix to ensure that it will be executed only once
*/
CREATE TABLE [dbo].[tblGLDataFixLog](
	[intLogId] [int] IDENTITY(1,1) NOT NULL,
	[dtmDate] [datetime] NULL,
	[strDescription] [nvarchar](100) COLLATE Latin1_General_CI_AS NULL,
 CONSTRAINT [PK_tblGLDataFixLog] PRIMARY KEY CLUSTERED 
(
	[intLogId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

