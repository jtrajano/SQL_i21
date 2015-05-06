CREATE TABLE [dbo].[tblQMComputationType]
(
	[intComputationTypeId] INT NOT NULL, 
	[strComputationTypeName] NVARCHAR(100) COLLATE Latin1_General_CI_AS NOT NULL, 

	CONSTRAINT [PK_tblQMComputationType] PRIMARY KEY ([intComputationTypeId]), 
	CONSTRAINT [AK_tblQMComputationType_strComputationTypeName] UNIQUE ([strComputationTypeName]) 
)