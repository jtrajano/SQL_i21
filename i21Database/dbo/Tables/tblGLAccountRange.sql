CREATE TABLE [dbo].[tblGLAccountRange](
	[intAccountRangeId] [int] IDENTITY(1,1) NOT NULL,
	[strAccountType]  NVARCHAR(20) COLLATE Latin1_General_CI_AS NULL,
	[intMinRange] [int] NULL,
	[intMaxRange] [int] NULL,
 CONSTRAINT [PK_tblGLAccountRange] PRIMARY KEY CLUSTERED 
(
	[intAccountRangeId] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

