CREATE TABLE [dbo].[tblGLSegmentType](
	[intSegmentTypeId] [int] IDENTITY(1,1) NOT NULL,
	[strSegmentType] [nvarchar](50) NULL,
	[intConcurrencyId] [int] NOT NULL,
 CONSTRAINT [PK_tblGLSegmentType] PRIMARY KEY CLUSTERED 
(
	[intSegmentTypeId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Segment Type Id' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLSegmentType', @level2type=N'COLUMN',@level2name=N'intSegmentTypeId'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Segment Type' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLSegmentType', @level2type=N'COLUMN',@level2name=N'strSegmentType'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Concurrency Id' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLSegmentType', @level2type=N'COLUMN',@level2name=N'intConcurrencyId'
GO


