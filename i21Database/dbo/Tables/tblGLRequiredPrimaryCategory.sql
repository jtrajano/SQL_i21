CREATE TABLE [dbo].[tblGLRequiredPrimaryCategory](
	[intRequiredPrimaryCategoryId] [int] IDENTITY(1,1) NOT NULL,
	[intAccountCategoryId] [int] NULL,
	[intModuleId] [int] NULL,
	[strScreen] [NVARCHAR](100)  COLLATE Latin1_General_CI_AS NULL,
	[strView] [NVARCHAR](300)  COLLATE Latin1_General_CI_AS NULL,
	[strTab] [NVARCHAR](50)  COLLATE Latin1_General_CI_AS NULL
 CONSTRAINT [PK_tblGLRequiredPrimaryCategorY] PRIMARY KEY CLUSTERED 
(
	[intRequiredPrimaryCategoryId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)
GO

