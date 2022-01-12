CREATE TABLE [dbo].[tblApiSchemaTransformCategoryAccount] (
	intKey INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    guiApiUniqueId UNIQUEIDENTIFIER NOT NULL,
    intRowNumber INT NULL,
	strCategoryCode NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL, -- The category code.
	strAccountCategory NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL, -- The GL account category.
	strAccountId NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL, -- The GL account ID.
)