CREATE TABLE [dbo].[tblTFComponentType]
(
	[intComponentTypeId] INT IDENTITY NOT NULL, 
    [strComponentType] NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL, 
    [intConcurrencyId] INT NULL DEFAULT ((1)), 
    CONSTRAINT [PK_tblTFComponentType] PRIMARY KEY ([intComponentTypeId]), 
    CONSTRAINT [UK_tblTFComponentType_strComponentType] UNIQUE ([strComponentType]) 
)
