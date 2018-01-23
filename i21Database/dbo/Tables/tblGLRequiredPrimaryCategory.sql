CREATE TABLE [dbo].[tblGLRequiredPrimaryCategory](
	[intRequiredPrimaryCategoryId] [int] IDENTITY(1,1) NOT NULL,
	[intAccountCategoryId] [int] NULL,
	[intModuleId] [int] NULL
 CONSTRAINT [PK_tblGLRequiredPrimaryCategorY] PRIMARY KEY CLUSTERED 
(
	[intRequiredPrimaryCategoryId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

