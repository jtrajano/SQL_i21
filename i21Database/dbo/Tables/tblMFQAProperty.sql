CREATE TABLE [dbo].[tblMFQAProperty]
(
	[intQAPropertyId] INT NOT NULL IDENTITY, 
    [strPropertyName] NVARCHAR(50) NOT NULL, 
    [strDescription] NVARCHAR(100) NOT NULL, 
    [strAnalysisType] NVARCHAR(50) NOT NULL, 
    [strDataType] NVARCHAR(50) NOT NULL, 
    [strListName] NVARCHAR(50) NULL, 
    [intDecimalPlaces] INT NULL DEFAULT ((2)), 
    [strMandatory] NVARCHAR(50) NULL , 
    [ysnActive] BIT NULL DEFAULT ((1)), 
    [intConcurrencyId] INT NULL DEFAULT ((0)), 
    CONSTRAINT [PK_tblMFQAProperty] PRIMARY KEY ([intQAPropertyId]), 
    CONSTRAINT [AK_tblMFQAProperty_strPropertyName] UNIQUE ([strPropertyName]) 
)
