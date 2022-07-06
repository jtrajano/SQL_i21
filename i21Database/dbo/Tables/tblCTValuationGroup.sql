CREATE TABLE [dbo].[tblCTValuationGroup]
(
	[intValuationGroupId] INT IDENTITY NOT NULL, 
    [strName] NVARCHAR(50) NOT NULL, 
    [strDescription] NVARCHAR(100) NULL, 
    [intConcurrencyId] INT NULL DEFAULT((0)), 
    CONSTRAINT [PK_tblCTValuationGroup] PRIMARY KEY ([intValuationGroupId]) 
)
