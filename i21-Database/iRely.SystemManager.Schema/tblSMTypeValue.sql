CREATE TABLE [dbo].[tblSMTypeValue]
(
    [intTypeValueId] INT NOT NULL PRIMARY KEY IDENTITY, 
    [strType] NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL, 
    [strValue] NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL, 
	[ysnDefault] BIT NULL, 
    [intConcurrencyId] INT NOT NULL DEFAULT 1,
	CONSTRAINT [UC_Type_Value] UNIQUE ([strType], [strValue])
)
