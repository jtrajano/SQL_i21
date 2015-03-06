CREATE TABLE [dbo].[tblGLAccountCategoryGroup](
	[intAccountCategoryGroupId] [int] IDENTITY(1,1) NOT NULL,
	[intAccountCategoryId] [int] NULL,
	[strAccountCategoryGroupDesc] NVARCHAR (30)  COLLATE Latin1_General_CI_AS NULL,
	[strAccountCategoryGroupCode] NVARCHAR (5)  COLLATE Latin1_General_CI_AS NULL,
 CONSTRAINT [PK_tblGLAccountCategoryGroup] PRIMARY KEY CLUSTERED 
(
	[intAccountCategoryGroupId] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

ALTER TABLE [dbo].[tblGLAccountCategoryGroup]  WITH CHECK ADD  CONSTRAINT [FK_tblGLAccountCategoryGroup_tblGLAccountCategory] FOREIGN KEY([intAccountCategoryId])
REFERENCES [dbo].[tblGLAccountCategory] ([intAccountCategoryId])
GO

ALTER TABLE [dbo].[tblGLAccountCategoryGroup] CHECK CONSTRAINT [FK_tblGLAccountCategoryGroup_tblGLAccountCategory]
GO