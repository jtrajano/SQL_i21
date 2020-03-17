CREATE TABLE [dbo].[tblRKM2MType]
(
	[intM2MTypeId] INT NOT NULL IDENTITY, 
    [strType] NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL, 
    [intConcurrencyId] INT NULL DEFAULT ((1)), 
    CONSTRAINT [PK_tblRKM2MType] PRIMARY KEY ([intM2MTypeId]), 
    CONSTRAINT [AK_tblRKM2MType_strType] UNIQUE ([strType])
)
