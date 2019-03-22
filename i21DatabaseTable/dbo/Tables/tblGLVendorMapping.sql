CREATE TABLE [dbo].[tblGLVendorMapping](
	[intVendorMappingId] [int] IDENTITY(1,1) NOT NULL,
	[strDescription] [nvarchar](50) COLLATE Latin1_General_CI_AS NOT NULL,
	[intConcurrencyId] [int] NULL,
 CONSTRAINT [PK_tblGLVendorMapping] PRIMARY KEY CLUSTERED 
(
	[intVendorMappingId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [IX_tblGLVendorMapping_strDescription] UNIQUE NONCLUSTERED 
(
	[strDescription] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Table Primary Key' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLVendorMapping', @level2type=N'COLUMN',@level2name=N'intVendorMappingId'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Description' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLVendorMapping', @level2type=N'COLUMN',@level2name=N'strDescription'
GO
