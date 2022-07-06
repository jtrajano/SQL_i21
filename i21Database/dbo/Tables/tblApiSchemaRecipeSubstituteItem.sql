CREATE TABLE [dbo].[tblApiSchemaRecipeSubstituteItem]
(
	[intKey] INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    [guiApiUniqueId] UNIQUEIDENTIFIER NOT NULL,
    [intRowNumber] INT NULL,

    [strRecipeName] NVARCHAR(250) COLLATE Latin1_General_CI_AS NULL,
	[strRecipeHeaderItemNo] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	[strLocationName] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
    [strRecipeItemNo] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
    [strSubstituteItemNo] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
    [dblSubstituteRatio] DECIMAL(38, 20) NULL,
    [dblMaxSubstituteRatio] DECIMAL(38, 20) NULL
)