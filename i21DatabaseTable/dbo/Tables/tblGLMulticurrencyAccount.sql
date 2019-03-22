CREATE TABLE [dbo].[tblGLMulticurrencyAccount](
	[intMulticurrencyAccountId] [int] IDENTITY(1,1) NOT NULL,
	[intAccountId] [int] NULL,
	[strDescription] [nvarchar](100)  COLLATE Latin1_General_CI_AS NULL,
	[intConcurrencyId] [int] NULL,
 CONSTRAINT [PK_tblGLMulticurrencyAccount] PRIMARY KEY CLUSTERED 
(
	[intMulticurrencyAccountId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]


