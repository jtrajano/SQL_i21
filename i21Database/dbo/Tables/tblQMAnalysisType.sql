CREATE TABLE [dbo].[tblQMAnalysisType]
(
	[intAnalysisTypeId] INT NOT NULL, 
	[strAnalysisTypeName] NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL, 
	[strDescription] NVARCHAR(100) COLLATE Latin1_General_CI_AS NOT NULL, 

	CONSTRAINT [PK_tblQMAnalysisType] PRIMARY KEY ([intAnalysisTypeId])
)