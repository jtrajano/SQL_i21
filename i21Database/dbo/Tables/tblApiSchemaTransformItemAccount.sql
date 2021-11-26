CREATE TABLE [dbo].[tblApiSchemaTransformItemAccount] (
	intKey INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    guiApiUniqueId UNIQUEIDENTIFIER NOT NULL,
    intRowNumber INT NULL,
	strItemNo NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL, -- The item number.
	strAccountCategory NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL, -- The item GL account.
	strAccountId NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL, -- The item GL account ID.
)