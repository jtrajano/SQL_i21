CREATE TABLE [dbo].[tblGLAccountSystem](
	[intAccountSystemId]			INT IDENTITY(1,1)	NOT NULL,
	[strAccountSystemDescription]	NVARCHAR(50)		COLLATE Latin1_General_CI_AS NULL,
	[ysnSystem]						BIT					NULL,
	[intConcurrencyId]				INT					NULL,
 CONSTRAINT [PK_tblGLAccountSystem] PRIMARY KEY CLUSTERED 
(
	[intAccountSystemId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Table Primary Key' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLAccountSystem', @level2type=N'COLUMN',@level2name=N'intAccountSystemId' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Account System Description' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLAccountSystem', @level2type=N'COLUMN',@level2name=N'strAccountSystemDescription' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'System Defined?' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLAccountSystem', @level2type=N'COLUMN',@level2name=N'ysnSystem' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Concurrency Id' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLAccountSystem', @level2type=N'COLUMN',@level2name=N'intConcurrencyId' 

GO