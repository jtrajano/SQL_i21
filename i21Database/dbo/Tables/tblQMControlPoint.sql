CREATE TABLE [dbo].[tblQMControlPoint]
(
	[intControlPointId] INT NOT NULL IDENTITY, 
	[strControlPointName] NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL, 
	[strDescription] NVARCHAR(100) COLLATE Latin1_General_CI_AS, 

	CONSTRAINT [PK_tblQMControlPoint] PRIMARY KEY ([intControlPointId]), 
	CONSTRAINT [AK_tblQMControlPoint_strControlPointName] UNIQUE ([strControlPointName]) 
)