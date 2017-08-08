CREATE TABLE [dbo].[tblGLConsolidateResult](
	[intConsolidateResultId] [int] IDENTITY(1,1) NOT NULL,
	[ysnFiscalOpen] [bit] NULL,
	[ysnUnpostedTrans] [bit] NULL,
	[strResult] [nvarchar](1000) NULL,
	[strCompanyName] [nvarchar](100) NULL,
 CONSTRAINT [PK_tblGLConsolidateResult] PRIMARY KEY CLUSTERED 
(
	[intConsolidateResultId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO