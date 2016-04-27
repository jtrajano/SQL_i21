CREATE TABLE [dbo].[tblGLTempCOASegment](
	[intAccountId] [int] NOT NULL,
	[strAccountId] [nvarchar](40) NOT NULL,
	[Primary Account] [nvarchar](20) NULL,
	[Location] [nvarchar](20) NULL,
	[LOB] [nvarchar](20) NULL,
 CONSTRAINT [PK_tblGLTempCOASegment] PRIMARY KEY CLUSTERED 
(
	[intAccountId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
