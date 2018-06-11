CREATE TABLE [dbo].[tblGLCrossReferenceMapping](
	[intCrossReferenceMappingId] [int] IDENTITY(1,1) NOT NULL,
	[strOldAccountId] NVARCHAR(50) COLLATE Latin1_General_CI_AS,
	[intAccountId] INT NULL,
	[intAccountSystemId] INT NULL,
	[ysnOutbound] BIT NULL,
	[ysnInbound] BIT NULL,
	[intConcurrencyId] INT
 CONSTRAINT [PK_tblGLCrossReferenceMapping] PRIMARY KEY CLUSTERED 
(
	[intCrossReferenceMappingId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO

ALTER TABLE [dbo].[tblGLCrossReferenceMapping]  WITH CHECK ADD  CONSTRAINT [FK_tblGLCrossReferenceMapping_tblGLAccount] FOREIGN KEY([intAccountId])
REFERENCES [dbo].[tblGLAccount] ([intAccountId])
GO

ALTER TABLE [dbo].[tblGLCrossReferenceMapping] CHECK CONSTRAINT [FK_tblGLCrossReferenceMapping_tblGLAccount]
GO

ALTER TABLE [dbo].[tblGLCrossReferenceMapping]  WITH CHECK ADD  CONSTRAINT [FK_tblGLCrossReferenceMapping_tblGLAccountSystem] FOREIGN KEY([intAccountSystemId])
REFERENCES [dbo].[tblGLAccountSystem] ([intAccountSystemId])
ON DELETE CASCADE
GO

ALTER TABLE [dbo].[tblGLCrossReferenceMapping] CHECK CONSTRAINT [FK_tblGLCrossReferenceMapping_tblGLAccountSystem]
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Table Primary Key' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLCrossReferenceMapping', @level2type=N'COLUMN',@level2name=N'intCrossReferenceMappingId' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Old Account Id' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLCrossReferenceMapping', @level2type=N'COLUMN',@level2name=N'strOldAccountId' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Account Id' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLCrossReferenceMapping', @level2type=N'COLUMN',@level2name=N'intAccountId' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Account System Id' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLCrossReferenceMapping', @level2type=N'COLUMN',@level2name=N'intAccountSystemId' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Outbound' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLCrossReferenceMapping', @level2type=N'COLUMN',@level2name=N'ysnOutbound' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Inbound' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLCrossReferenceMapping', @level2type=N'COLUMN',@level2name=N'ysnInbound' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Concurrency Id' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLCrossReferenceMapping', @level2type=N'COLUMN',@level2name=N'intConcurrencyId' 
GO