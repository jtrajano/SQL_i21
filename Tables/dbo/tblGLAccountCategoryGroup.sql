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
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Table Primary Key' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLAccountCategoryGroup', @level2type=N'COLUMN',@level2name=N'intAccountCategoryGroupId' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Account Category Id' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLAccountCategoryGroup', @level2type=N'COLUMN',@level2name=N'intAccountCategoryId' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Account Category Group Description' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLAccountCategoryGroup', @level2type=N'COLUMN',@level2name=N'strAccountCategoryGroupDesc' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Account Category Group Code' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLAccountCategoryGroup', @level2type=N'COLUMN',@level2name=N'strAccountCategoryGroupCode' 
GO