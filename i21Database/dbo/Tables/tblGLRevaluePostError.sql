CREATE TABLE [dbo].[tblGLRevaluePostError](
    [intId] [int] IDENTITY(1,1) NOT NULL,
	[strPostBatchId] [nvarchar](40) COLLATE Latin1_General_CI_AS NULL,
	[strMessage] [nvarchar](max) COLLATE Latin1_General_CI_AS NULL,
	[strTransactionId] [nvarchar](40) COLLATE Latin1_General_CI_AS NULL,
 CONSTRAINT [PK_tblGLRevaluePostError] PRIMARY KEY CLUSTERED 
(
	[intId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

