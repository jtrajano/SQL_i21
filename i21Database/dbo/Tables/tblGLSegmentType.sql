CREATE TABLE [dbo].[tblGLSegmentType]
(
	[intSegmentTypeId] INT NOT NULL PRIMARY KEY, 
    [strSegmentType] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	[intConcurrencyId] INT NOT NULL
)
