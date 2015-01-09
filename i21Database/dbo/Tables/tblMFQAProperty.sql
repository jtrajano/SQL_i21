CREATE TABLE [dbo].[tblMFQAProperty]
(
	[intQAPropertyId] INT NOT NULL IDENTITY, 
    [strPropertyName] NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL, 
    [strDescription] NVARCHAR(100) COLLATE Latin1_General_CI_AS NOT NULL, 
    [strAnalysisType] NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL, 
    [strDataType] NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL, 
    [strListName] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
    [intDecimalPlaces] INT NULL DEFAULT ((2)), 
    [strMandatory] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL , 
    [ysnActive] BIT NULL DEFAULT ((1)), 
    [intConcurrencyId] INT NULL DEFAULT ((0)), 
    CONSTRAINT [PK_tblMFQAProperty] PRIMARY KEY ([intQAPropertyId]), 
    CONSTRAINT [AK_tblMFQAProperty_strPropertyName] UNIQUE ([strPropertyName]) 
)
