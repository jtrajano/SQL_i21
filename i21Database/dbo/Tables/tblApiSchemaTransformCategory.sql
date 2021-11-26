CREATE TABLE [dbo].[tblApiSchemaTransformCategory] (
	intKey INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    guiApiUniqueId UNIQUEIDENTIFIER NOT NULL,
    intRowNumber INT NULL,
	strCategoryCode NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL, -- The category code.
	strDescription NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL, -- The category description.
	strLineOfBusiness NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL, -- The category line of business.
)