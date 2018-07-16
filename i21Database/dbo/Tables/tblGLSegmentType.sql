CREATE TABLE [dbo].[tblGLSegmentType]
(
	[intSegmentTypeId] INT IDENTITY(1,1) NOT NULL,
    [strSegmentType] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	[intConcurrencyId] INT NOT NULL
)
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Segment Type Id' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLSegmentType', @level2type=N'COLUMN',@level2name=N'intSegmentTypeId' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Segment Type' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLSegmentType', @level2type=N'COLUMN',@level2name=N'strSegmentType' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Concurrency Id' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLSegmentType', @level2type=N'COLUMN',@level2name=N'intConcurrencyId' 
GO
