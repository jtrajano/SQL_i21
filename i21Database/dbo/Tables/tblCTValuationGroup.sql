CREATE TABLE [dbo].[tblCTValuationGroup]
(
	[intValuationGroupId] INT IDENTITY NOT NULL, 
    [strName] NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL, 
    [strDescription] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL, 
    [intConcurrencyId] INT NULL DEFAULT((0)), 
    CONSTRAINT [PK_tblCTValuationGroup] PRIMARY KEY ([intValuationGroupId]) 
)
