CREATE TABLE [dbo].[tblGLVendorMappingDetail](
	[intVendorMappingDetailId] [int] IDENTITY(1,1) NOT NULL,
	[intVendorMappingId] [int] NOT NULL,
	[strMapVendorName] [nvarchar](100) COLLATE Latin1_General_CI_AS NOT NULL,
	[intEntityVendorId] [int] NOT NULL,
	[intConcurrencyId] [int] NULL,
 CONSTRAINT [PK_tblGLVendorMappingDetail] PRIMARY KEY CLUSTERED 
(
	[intVendorMappingDetailId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Table Primary Key' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLVendorMappingDetail', @level2type=N'COLUMN',@level2name=N'intVendorMappingDetailId'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Foreign key to tblGLVendorMapping' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLVendorMappingDetail', @level2type=N'COLUMN',@level2name=N'intVendorMappingId'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Vendor Name Mapping' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLVendorMappingDetail', @level2type=N'COLUMN',@level2name=N'strMapVendorName'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Foreign key to tblAPVendor' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLVendorMappingDetail', @level2type=N'COLUMN',@level2name=N'intEntityVendorId'
GO

