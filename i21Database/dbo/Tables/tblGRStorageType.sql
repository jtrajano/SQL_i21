CREATE TABLE [dbo].[tblGRStorageType]
(
	[intStorageTypeId] INT NOT NULL IDENTITY, 
    [strStorageType] NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL, 
    [strDescription] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL, 
    [intSort] INT NULL, 
    [intConcurrencyId] INT NULL DEFAULT ((0)), 
    CONSTRAINT [PK_tblGRStorageType] PRIMARY KEY ([intStorageTypeId]), 
    CONSTRAINT [AK_tblGRStorageType_strStorageType] UNIQUE ([strStorageType])
)
